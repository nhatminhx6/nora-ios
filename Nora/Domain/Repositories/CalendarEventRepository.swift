import Foundation
import SwiftData

@MainActor
final class CalendarEventRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [CalendarEvent] {
        let descriptor = FetchDescriptor<CalendarEventEntity>(
            sortBy: [SortDescriptor(\.startDate)]
        )
        return try modelContext.fetch(descriptor).map { $0.asDomainModel() }
    }

    func save(_ event: CalendarEvent) throws {
        modelContext.insert(CalendarEventEntity(event: event))
        try modelContext.save()
    }

    func delete(id: UUID) throws {
        let descriptor = FetchDescriptor<CalendarEventEntity>(
            predicate: #Predicate { $0.id == id }
        )
        if let entity = try modelContext.fetch(descriptor).first {
            modelContext.delete(entity)
            try modelContext.save()
        }
    }
}
