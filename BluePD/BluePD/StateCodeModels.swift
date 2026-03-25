import Foundation

struct StateCodeCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let statutes: [StateStatute]
}

struct StateStatute: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let statuteNumber: String
    let description: String
    let notes: String
}

struct StateCodeEntry: Identifiable, Hashable {
    let id = UUID()
    let stateName: String
    let categories: [StateCodeCategory]
}
