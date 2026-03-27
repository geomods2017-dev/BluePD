import Foundation

struct SavedSFSTReport: Identifiable, Codable {
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
