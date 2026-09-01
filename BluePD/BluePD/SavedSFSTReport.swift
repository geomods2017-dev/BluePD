import Foundation

struct SavedSFSTReport: Identifiable, Codable, Equatable {
    let id: UUID
    let subjectName: String
    let createdAt: Date
    let reportText: String

    init(id: UUID = UUID(), subjectName: String, createdAt: Date = Date(), reportText: String) {
        self.id = id
        self.subjectName = subjectName
        self.createdAt = createdAt
        self.reportText = reportText
    }
}

/// Local disk persistence for saved SFST reports, mirroring the pattern already used by
/// `EvidenceStorage` and `QuickCardsView`'s card store.
///
/// Previously, saved SFST reports lived only in an in-memory array passed around as a
/// SwiftUI `Binding` — every completed DUI/field-sobriety report was silently lost the
/// moment the app was force-quit or the device restarted. This is the fix.
enum SavedSFSTReportStore {
    private static var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("saved_sfst_reports.json")
    }

    static func load() -> [SavedSFSTReport] {
        guard let data = try? Data(contentsOf: fileURL),
              let reports = try? JSONDecoder().decode([SavedSFSTReport].self, from: data) else {
            return []
        }
        return reports
    }

    static func save(_ reports: [SavedSFSTReport]) {
        guard let data = try? JSONEncoder().encode(reports) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
