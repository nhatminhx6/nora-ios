import Foundation

@MainActor
@Observable
final class TopicDetailStore {
    private(set) var topic: Topic?
    private(set) var insights: [Insight] = []
    private(set) var isLoading = true
    var naturalLanguageInput: String = ""
    var didConfirmEdit = false

    private let topicId: UUID
    private let topicRepository: TopicRepository
    private let topicService: TopicService

    init(topicId: UUID, environment: AppEnvironment) {
        self.topicId = topicId
        self.topicRepository = environment.topicRepository
        self.topicService = environment.topicService
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        topic = (try? topicRepository.fetchAll())?.first { $0.id == topicId }
        insights = (try? await topicService.fetchInsights(for: topicId)) ?? []
    }

    func updatePriority(_ priority: TopicPriority) {
        guard var topic else { return }
        topic.priority = priority
        persist(topic)
    }

    func updateNotificationMode(_ mode: TopicNotificationMode) {
        guard var topic else { return }
        topic.notificationMode = mode
        persist(topic)
    }

    /// Applies a free-text instruction as a new tracking rule — the
    /// natural-language editing affordance on the topic detail screen.
    func applyNaturalLanguageEdit() {
        guard var topic else { return }
        let instruction = naturalLanguageInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !instruction.isEmpty else { return }
        topic.trackingRules.append(instruction)
        persist(topic)
        naturalLanguageInput = ""
        didConfirmEdit = true
        Haptics.play(.success)
    }

    private func persist(_ topic: Topic) {
        self.topic = topic
        try? topicRepository.upsert(topic)
        Haptics.play(.light)
    }
}
