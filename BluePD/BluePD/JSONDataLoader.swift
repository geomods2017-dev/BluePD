import Foundation

final class JSONDataLoader {
    static let shared = JSONDataLoader()

    private init() {}

    func load<T: Decodable>(_ filename: String, as type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Could not find \(filename).json")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            print("Failed to decode \(filename).json: \(error)")
            return nil
        }
    }
}
