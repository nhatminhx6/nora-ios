import Foundation
import SwiftData

/// Bridges `UserProfile` domain models to SwiftData. Views and stores talk
/// to this repository, never to `ModelContext` directly.
@MainActor
final class ProfileRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetch() throws -> UserProfile? {
        var descriptor = FetchDescriptor<UserProfileEntity>()
        descriptor.fetchLimit = 1
        let entity = try modelContext.fetch(descriptor).first
        return entity?.asDomainModel()
    }

    func save(_ profile: UserProfile) throws {
        var descriptor = FetchDescriptor<UserProfileEntity>(
            predicate: #Predicate { $0.id == profile.id }
        )
        descriptor.fetchLimit = 1

        if let existing = try modelContext.fetch(descriptor).first {
            existing.apply(profile)
        } else {
            modelContext.insert(UserProfileEntity(profile: profile))
        }
        try modelContext.save()
    }

    func deleteAll() throws {
        try modelContext.delete(model: UserProfileEntity.self)
        try modelContext.save()
    }
}
