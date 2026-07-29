import Foundation
import SwiftData

@Model
final class CalendarEventEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var notes: String
    var startDate: Date
    var isAllDay: Bool
    var reminderMinutes: Int?
    var createdAt: Date

    init(event: CalendarEvent) {
        id = event.id
        title = event.title
        notes = event.notes
        startDate = event.startDate
        isAllDay = event.isAllDay
        reminderMinutes = event.reminderMinutes
        createdAt = event.createdAt
    }

    func asDomainModel() -> CalendarEvent {
        CalendarEvent(
            id: id,
            title: title,
            notes: notes,
            startDate: startDate,
            isAllDay: isAllDay,
            reminderMinutes: reminderMinutes,
            createdAt: createdAt
        )
    }
}
