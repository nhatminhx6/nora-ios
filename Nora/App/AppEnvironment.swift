import Foundation
import SwiftData

/// Simple, explicit dependency container — every service is protocol-typed
/// so mocks can be swapped in for previews and tests without a DI
/// framework.
@MainActor
@Observable
final class AppEnvironment {
    let profileService: ProfileService
    let topicService: TopicService
    let briefService: BriefService
    let assistantService: AssistantService
    let notificationService: NotificationService

    let profileRepository: ProfileRepository
    let topicRepository: TopicRepository
    let savedInsightRepository: SavedInsightRepository

    let localization: LocalizationManager

    init(modelContext: ModelContext, localization: LocalizationManager = LocalizationManager()) {
        self.localization = localization

        self.profileService = MockProfileService()
        self.topicService = MockTopicService()
        self.briefService = MockBriefService()
        self.assistantService = MockAssistantService()
        self.notificationService = MockNotificationService()

        self.profileRepository = ProfileRepository(modelContext: modelContext)
        self.topicRepository = TopicRepository(modelContext: modelContext)
        self.savedInsightRepository = SavedInsightRepository(modelContext: modelContext)

        try? topicRepository.seedIfNeeded(with: PreviewData.allTopics)
    }

    /// Preview/test convenience using an in-memory store and mock services.
    static func preview() -> AppEnvironment {
        let container = NoraModelContainer.inMemory()
        return AppEnvironment(modelContext: container.mainContext)
    }
}
