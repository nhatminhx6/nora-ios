import Foundation

protocol AuthService: Sendable {
    func login(email: String, password: String) async throws -> LoginResponse
}

enum AuthServiceError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case server(message: String)
    case connection

    var errorDescription: String? {
        switch self {
        case .invalidURL, .invalidResponse:
            "Nora received an unexpected response. Please try again."
        case .server(let message):
            message
        case .connection:
            "Couldn't connect to Nora. Check your connection and try again."
        }
    }
}

struct LiveAuthService: AuthService {
    private let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        do {
            return try await client.send(
                "auth/login",
                method: "POST",
                body: LoginRequest(email: email, password: password),
                authenticated: false
            )
        } catch let error as APIClientError {
            if case .server(let message) = error { throw AuthServiceError.server(message: message) }
            if case .connection = error { throw AuthServiceError.connection }
            throw AuthServiceError.invalidResponse
        } catch {
            throw AuthServiceError.connection
        }
    }
}

private struct LoginRequest: Encodable {
    let email: String
    let password: String
}
