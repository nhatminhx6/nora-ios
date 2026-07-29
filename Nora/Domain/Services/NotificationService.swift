import Foundation
import UserNotifications

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
    func schedule(event: CalendarEvent) async throws
    func cancelEventReminder(id: UUID) async
}

actor LiveNotificationService: NotificationService {
    private let center = UNUserNotificationCenter.current()

    func authorizationStatus() async -> NotificationAuthorizationStatus {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    func scheduleDailyBrief(at time: DateComponents) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Your Nora brief is ready"
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: time.hour, minute: time.minute),
            repeats: true
        )
        try await center.add(UNNotificationRequest(identifier: "nora.dailyBrief", content: content, trigger: trigger))
    }

    func schedule(event: CalendarEvent) async throws {
        guard let minutes = event.reminderMinutes else { return }
        let fireDate = event.startDate.addingTimeInterval(TimeInterval(-minutes * 60))
        guard fireDate > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = event.title
        content.body = event.notes.isEmpty ? "Upcoming event" : event.notes
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        try await center.add(
            UNNotificationRequest(
                identifier: "nora.event.\(event.id.uuidString)",
                content: content,
                trigger: trigger
            )
        )
    }

    func cancelEventReminder(id: UUID) async {
        center.removePendingNotificationRequests(withIdentifiers: ["nora.event.\(id.uuidString)"])
    }
}
