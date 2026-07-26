import Foundation
import SwiftData

@MainActor
final class SavedInsightRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [Insight] {
        let descriptor = FetchDescriptor<SavedInsightEntity>(sortBy: [SortDescriptor(\.savedAt, order: .reverse)])
        return try modelContext.fetch(descriptor).compactMap { $0.asDomainModel() }
    }

    func save(_ insight: Insight) throws {
        var descriptor = FetchDescriptor<SavedInsightEntity>(predicate: #Predicate { $0.id == insight.id })
        descriptor.fetchLimit = 1
        guard try modelContext.fetch(descriptor).first == nil else { return }
        modelContext.insert(SavedInsightEntity(insight: insight))
        try modelContext.save()
    }

    func remove(id: UUID) throws {
        var descriptor = FetchDescriptor<SavedInsightEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        if let existing = try modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
            try modelContext.save()
        }
    }
}
