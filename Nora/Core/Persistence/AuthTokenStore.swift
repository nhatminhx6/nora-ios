import Foundation
import Security

struct AuthTokenStore: Sendable {
    private let service = "com.nora.app.auth"
    private let account = "session"

    func load() -> LoginResponse? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        guard let session = try? JSONDecoder().decode(LoginResponse.self, from: data),
              !isExpired(session.accessToken) else {
            clear()
            return nil
        }
        return session
    }

    func save(_ session: LoginResponse) throws {
        let data = try JSONEncoder().encode(session)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)
        let attributes = query.merging([
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]) { _, new in new }
        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else { throw AuthTokenStoreError.saveFailed(status) }
    }

    func clear() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)
    }

    /// UserDefaults is removed when the app is uninstalled while Keychain
    /// survives. In Debug, that difference lets us detect a fresh install
    /// and discard stale development sessions automatically.
    func clearStaleSessionOnFreshDebugInstall() {
        #if DEBUG
        let marker = "nora.debug.hasLaunchedThisInstall"
        guard !UserDefaults.standard.bool(forKey: marker) else { return }
        clear()
        UserDefaults.standard.set(true, forKey: marker)
        #endif
    }

    private func isExpired(_ jwt: String) -> Bool {
        let segments = jwt.split(separator: ".")
        guard segments.count == 3 else { return true }

        var payload = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        payload.append(String(repeating: "=", count: (4 - payload.count % 4) % 4))

        guard let data = Data(base64Encoded: payload),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let expiration = object["exp"] as? TimeInterval else {
            return true
        }
        return Date().timeIntervalSince1970 >= expiration
    }
}

enum AuthTokenStoreError: Error {
    case saveFailed(OSStatus)
}
