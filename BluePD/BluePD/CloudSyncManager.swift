import Foundation
import CloudKit
import UIKit

enum CloudSyncStatus: Equatable {
    case idle
    case syncing
    case synced(Date)
    case unavailable(String)

    var displayText: String {
        switch self {
        case .idle:
            return "Not yet synced"
        case .syncing:
            return "Syncing..."
        case .synced(let date):
            return "Synced \(date.formatted(date: .omitted, time: .shortened))"
        case .unavailable(let reason):
            return reason
        }
    }

    var isHealthy: Bool {
        if case .unavailable = self { return false }
        return true
    }
}

/// Lightweight iCloud (CloudKit private database) backup/sync for saved SFST reports,
/// quick cards, the officer profile, and evidence photos — replacing the old disabled
/// demo login/session code, which never persisted anything anywhere.
///
/// Design, deliberately kept simple since this can't be compiled or tested in the
/// environment that wrote it:
/// - Reports, quick cards, and the officer profile are synced generically: each item is
///   JSON-encoded into a single CKRecord "payload" field, keyed by the item's own UUID.
///   This avoids hand-mapping every struct field to a CKRecord field three separate times.
/// - Evidence photos get their own push/pull pair because the image itself needs to travel
///   as a CKAsset, not just JSON.
/// - Sync is push-on-change (fire-and-forget from the call site right after a local save)
///   plus a pull-and-merge on launch/foreground. Merge is additive/last-write-wins by
///   `updatedAt` — there's no multi-device conflict UI. That's a reasonable scope for a
///   personal-device utility app, not a claim that this is a full sync engine.
///
/// Two manual, one-time setup steps this code can't do by itself (call these out to
/// whoever builds this in Xcode):
/// 1. Enable the iCloud capability (CloudKit) for this target in Xcode's Signing &
///    Capabilities tab, which provisions the `iCloud.com.bluepd.app` container.
/// 2. In the CloudKit Dashboard for that container, mark the `kind` field on the
///    `BluePDItem` record type as "Queryable" — CloudKit doesn't index new fields for
///    querying by default, and the pull-all-of-a-kind query here depends on that index.
@MainActor
final class CloudSyncManager: ObservableObject {
    @Published private(set) var status: CloudSyncStatus = .idle

    enum ItemKind: String {
        case report, evidence, card, profile
    }

    private let recordType = "BluePDItem"
    private let container = CKContainer.default()
    private lazy var database = container.privateCloudDatabase

    // MARK: - Availability

    func checkAccountStatus() async {
        do {
            let accountStatus = try await container.accountStatus()
            switch accountStatus {
            case .available:
                if !status.isHealthy { status = .idle }
            case .noAccount:
                status = .unavailable("Sign in to iCloud in device Settings to back up BluePD data.")
            case .restricted, .couldNotDetermine:
                status = .unavailable("iCloud is unavailable on this device.")
            case .temporarilyUnavailable:
                status = .unavailable("iCloud is temporarily unavailable.")
            @unknown default:
                status = .unavailable("iCloud status unknown.")
            }
        } catch {
            status = .unavailable("Could not reach iCloud: \(error.localizedDescription)")
        }
    }

    // MARK: - Generic JSON-payload sync (reports, cards, profile)

    private func recordID(kind: ItemKind, id: String) -> CKRecord.ID {
        CKRecord.ID(recordName: "\(kind.rawValue)-\(id)")
    }

    /// Uploads or updates a single Codable item under the given kind and id.
    @discardableResult
    func push<T: Encodable>(_ item: T, id: UUID, kind: ItemKind, updatedAt: Date = Date()) async -> Bool {
        guard let payload = try? JSONEncoder().encode(item) else { return false }

        let record = CKRecord(recordType: recordType, recordID: recordID(kind: kind, id: id.uuidString))
        record["kind"] = kind.rawValue as CKRecordValue
        record["payload"] = payload as CKRecordValue
        record["updatedAt"] = updatedAt as CKRecordValue

        status = .syncing

        do {
            _ = try await database.save(record)
            status = .synced(Date())
            return true
        } catch {
            status = .unavailable("Sync failed: \(error.localizedDescription)")
            return false
        }
    }

    func delete(id: UUID, kind: ItemKind) async {
        do {
            _ = try await database.deleteRecord(withID: recordID(kind: kind, id: id.uuidString))
        } catch {
            // Not fatal: the record may already be gone, or the device may be offline.
            // Local deletion has already happened; a later full sync will reconcile.
        }
    }

    /// Fetches every remote record of a kind and decodes it back to `T`, paired with its
    /// `updatedAt` so callers can merge (keep-newest, or additive-only) against local data.
    func pullAll<T: Decodable>(kind: ItemKind, as type: T.Type) async -> [(item: T, updatedAt: Date)] {
        let predicate = NSPredicate(format: "kind == %@", kind.rawValue)
        let query = CKQuery(recordType: recordType, predicate: predicate)

        do {
            let (matchResults, _) = try await database.records(matching: query)
            var results: [(T, Date)] = []

            for (_, result) in matchResults {
                guard case .success(let record) = result,
                      let payload = record["payload"] as? Data,
                      let updatedAt = record["updatedAt"] as? Date,
                      let item = try? JSONDecoder().decode(T.self, from: payload) else {
                    continue
                }
                results.append((item, updatedAt))
            }

            return results
        } catch {
            status = .unavailable("Could not fetch from iCloud: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Evidence (metadata + photo asset)

    /// Uploads an evidence record's metadata alongside its photo as a CKAsset.
    @discardableResult
    func pushEvidence(_ record: EvidenceRecord, image: UIImage, updatedAt: Date = Date()) async -> Bool {
        guard let payload = try? JSONEncoder().encode(record),
              let imageData = image.jpegData(compressionQuality: 0.8) else { return false }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")

        do {
            try imageData.write(to: tempURL)
        } catch {
            return false
        }
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let ckRecord = CKRecord(recordType: recordType, recordID: recordID(kind: .evidence, id: record.id.uuidString))
        ckRecord["kind"] = ItemKind.evidence.rawValue as CKRecordValue
        ckRecord["payload"] = payload as CKRecordValue
        ckRecord["updatedAt"] = updatedAt as CKRecordValue
        ckRecord["photo"] = CKAsset(fileURL: tempURL)

        status = .syncing

        do {
            _ = try await database.save(ckRecord)
            status = .synced(Date())
            return true
        } catch {
            status = .unavailable("Sync failed: \(error.localizedDescription)")
            return false
        }
    }

    /// Fetches every remote evidence record along with its photo bytes (if the asset
    /// downloaded successfully). Callers are responsible for writing the image to local
    /// evidence storage under a filename and inserting the manifest entry.
    func pullEvidence() async -> [(record: EvidenceRecord, imageData: Data?)] {
        let predicate = NSPredicate(format: "kind == %@", ItemKind.evidence.rawValue)
        let query = CKQuery(recordType: recordType, predicate: predicate)

        do {
            let (matchResults, _) = try await database.records(matching: query)
            var results: [(EvidenceRecord, Data?)] = []

            for (_, result) in matchResults {
                guard case .success(let ckRecord) = result,
                      let payload = ckRecord["payload"] as? Data,
                      let record = try? JSONDecoder().decode(EvidenceRecord.self, from: payload) else {
                    continue
                }

                var imageData: Data?
                if let asset = ckRecord["photo"] as? CKAsset, let fileURL = asset.fileURL {
                    imageData = try? Data(contentsOf: fileURL)
                }

                results.append((record, imageData))
            }

            return results
        } catch {
            status = .unavailable("Could not fetch from iCloud: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Merge helper

    /// Adds any remote items whose id isn't already present locally. Doesn't overwrite or
    /// remove local items — a conservative "never lose data" merge suited to a personal
    /// backup/sync feature rather than a full conflict-resolution engine. Used by Home
    /// (reports), Quick Cards, and Settings' manual "Restore from iCloud" action.
    nonisolated static func mergeAdditively<T: Identifiable>(
        local: [T],
        remote: [(item: T, updatedAt: Date)]
    ) -> [T] where T.ID == UUID {
        var result = local
        let localIDs = Set(local.map(\.id))

        for (item, _) in remote where !localIDs.contains(item.id) {
            result.append(item)
        }

        return result
    }
}
