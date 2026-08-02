import Foundation

@MainActor
@Observable
final class AuthSessionStore {
    private(set) var session: LoginResponse?
    private(set) var isSubmitting = false
    var errorMessage: String?

    private let authService: any AuthService
    private let tokenStore: AuthTokenStore

    init(authService: any AuthService, tokenStore: AuthTokenStore = AuthTokenStore()) {
        self.authService = authService
        self.tokenStore = tokenStore
        self.session = tokenStore.load()
    }

    var isAuthenticated: Bool { session != nil }

    func login(email: String, password: String) async {
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        do {
            let response = try await authService.login(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                password: password
            )
            try tokenStore.save(response)
            session = response
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Login failed. Please try again."
        }
    }

    func logout() {
        tokenStore.clear()
        session = nil
    }
}

