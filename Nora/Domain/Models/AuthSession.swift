import Foundation

struct AuthUser: Codable, Equatable, Sendable {
    let id: String
    let email: String
    let displayName: String
}

struct LoginResponse: Codable, Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
    let user: AuthUser
}

