import Foundation

struct CalendarEvent: Identifiable, Equatable {
    var id: UUID
    var title: String
    var notes: String
    var startDate: Date
    var isAllDay: Bool
    var reminderMinutes: Int?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        startDate: Date,
        isAllDay: Bool = false,
        reminderMinutes: Int? = 30,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.startDate = startDate
        self.isAllDay = isAllDay
        self.reminderMinutes = reminderMinutes
        self.createdAt = createdAt
    }
}
