import Foundation

enum NotificationAuthorizationStatus {
    case notDetermined
    case authorized
    case denied
}

/// Wraps local/push notification scheduling behind a protocol so the rest
/// of the app never touches `UNUserNotificationCenter` directly.
protocol NotificationService: Sendable {
    func authorizationStatus() async -> NotificationAuthorizationStatus
    func requestAuthorization() async throws -> Bool
    func scheduleDailyBrief(at time: DateComponents) async throws
}

actor MockNotificationService: NotificationService {
    private var status: NotificationAuthorizationStatus = .notDetermined

    func authorizationStatus() async -> NotificationAuthorizationStatus {
        status
    }

    func requestAuthorization() async throws -> Bool {
        status = .authorized
        return true
    }

    func scheduleDailyBrief(at time: DateComponents) async throws {
        try await Task.sleep(for: .milliseconds(100))
    }
}
