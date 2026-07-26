import Foundation
import SwiftData

@MainActor
final class TopicRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [Topic] {
        let descriptor = FetchDescriptor<TopicEntity>(sortBy: [SortDescriptor(\.createdAt)])
        return try modelContext.fetch(descriptor).compactMap { $0.asDomainModel() }
    }

    func upsert(_ topic: Topic) throws {
        var descriptor = FetchDescriptor<TopicEntity>(predicate: #Predicate { $0.id == topic.id })
        descriptor.fetchLimit = 1

        if let existing = try modelContext.fetch(descriptor).first {
            existing.apply(topic)
        } else {
            modelContext.insert(TopicEntity(topic: topic))
        }
        try modelContext.save()
    }

    func delete(id: UUID) throws {
        var descriptor = FetchDescriptor<TopicEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        if let existing = try modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
            try modelContext.save()
        }
    }

    /// Seeds the store the first time the app launches so the experience
    /// isn't empty before any onboarding or Assistant conversation happens.
    func seedIfNeeded(with topics: [Topic]) throws {
        guard try fetchAll().isEmpty else { return }
        for topic in topics {
            modelContext.insert(TopicEntity(topic: topic))
        }
        try modelContext.save()
    }
}
