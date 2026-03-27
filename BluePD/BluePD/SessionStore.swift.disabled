import Foundation

final class SessionStore: ObservableObject {
    @Published var username: String = "Officer"
    @Published var password: String = "1234"
    @Published var isLoggedIn: Bool = false

    func login(user: String, pass: String) -> Bool {
        guard !user.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !pass.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        username = user
        password = pass
        isLoggedIn = true
        return true
    }

    func logout() {
        isLoggedIn = false
    }
}
