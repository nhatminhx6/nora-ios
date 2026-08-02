import Foundation
import SwiftData

/// Simple, explicit dependency container — every service is protocol-typed
/// so mocks can be swapped in for previews and tests without a DI
/// framework.
@MainActor
@Observable
final class AppEnvironment {
    let authSession: AuthSessionStore
    let profileService: ProfileService
    let topicService: TopicService
    let briefService: BriefService
    let assistantService: AssistantService
    let notificationService: NotificationService

    let profileRepository: ProfileRepository
    let topicRepository: TopicRepository
    let savedInsightRepository: SavedInsightRepository
    let calendarEventRepository: CalendarEventRepository

    let localization: LocalizationManager

    init(
        modelContext: ModelContext,
        localization: LocalizationManager = LocalizationManager(),
        usesPreviewData: Bool = false
    ) {
        self.localization = localization
        self.authSession = AuthSessionStore(authService: LiveAuthService())

        self.profileService = usesPreviewData ? MockProfileService() : LiveProfileService()
        self.topicService = usesPreviewData ? MockTopicService() : LiveTopicService()
        self.briefService = usesPreviewData ? MockBriefService() : LiveBriefService()
        self.assistantService = usesPreviewData ? MockAssistantService() : LiveAssistantService()
        self.notificationService = LiveNotificationService()

        self.profileRepository = ProfileRepository(modelContext: modelContext)
        self.topicRepository = TopicRepository(modelContext: modelContext)
        self.savedInsightRepository = SavedInsightRepository(modelContext: modelContext)
        self.calendarEventRepository = CalendarEventRepository(modelContext: modelContext)

        if usesPreviewData {
            try? topicRepository.seedIfNeeded(with: PreviewData.allTopics)
        }
    }

    /// Preview/test convenience using an in-memory store and mock services.
    static func preview() -> AppEnvironment {
        let container = NoraModelContainer.inMemory()
        return AppEnvironment(modelContext: container.mainContext, usesPreviewData: true)
    }
}
