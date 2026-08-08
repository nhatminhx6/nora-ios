import Foundation

@MainActor
@Observable
final class CalendarStore {
    private(set) var events: [CalendarEvent] = []
    var visibleMonth: Date
    var selectedDate: Date
    private(set) var isScheduling = false

    private let repository: CalendarEventRepository
    private let notificationService: NotificationService
    private let calendar = Calendar.current

    init(environment: AppEnvironment) {
        repository = environment.calendarEventRepository
        notificationService = environment.notificationService
        let today = Date.now
        visibleMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
        selectedDate = today
    }

    func load() {
        events = (try? repository.fetchAll()) ?? []
    }

    func moveMonth(by value: Int) {
        visibleMonth = calendar.date(byAdding: .month, value: value, to: visibleMonth) ?? visibleMonth
    }

    func events(on date: Date) -> [CalendarEvent] {
        events.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
    }

    func add(_ event: CalendarEvent) async {
        guard !isScheduling else { return }
        isScheduling = true
        defer { isScheduling = false }
        try? repository.save(event)
        let status = await notificationService.authorizationStatus()
        if status == .notDetermined {
            _ = try? await notificationService.requestAuthorization()
        }
        try? await notificationService.schedule(event: event)
        load()
        Haptics.play(.success)
    }

    func delete(_ event: CalendarEvent) {
        try? repository.delete(id: event.id)
        Task { await notificationService.cancelEventReminder(id: event.id) }
        load()
        Haptics.play(.medium)
    }
}
