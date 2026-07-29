import SwiftData

/// Central place that defines the SwiftData schema so every entity is
/// registered exactly once.
enum NoraModelContainer {
    static var schema: Schema {
        Schema([
            UserProfileEntity.self,
            TopicEntity.self,
            SavedInsightEntity.self,
            CalendarEventEntity.self,
        ])
    }

    /// Live, on-disk container used by the running app.
    static func live() -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return (try? ModelContainer(for: schema, configurations: [configuration]))
            ?? inMemory()
    }

    /// In-memory container used by SwiftUI Previews and tests.
    static func inMemory() -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        // Force-try is acceptable here: an in-memory container with a valid
        // static schema cannot realistically fail to initialize.
        return try! ModelContainer(for: schema, configurations: [configuration])
    }
}
