import Foundation

struct MirandaWarning: Codable, Identifiable {
    let id = UUID()
    let title: String
    let text: String

    enum CodingKeys: String, CodingKey {
        case title, text
    }
}

struct CaseLawItem: Codable, Identifiable {
    let id = UUID()
    let title: String
    let court: String
    let date: String
    let summary: String
    let citation: String

    enum CodingKeys: String, CodingKey {
        case title, court, date, summary, citation
    }
}

struct StateStatute: Codable, Identifiable {
    let id = UUID()
    let state: String
    let codeTitle: String
    let summary: String
    let link: String

    enum CodingKeys: String, CodingKey {
        case state, codeTitle, summary, link
    }
}
