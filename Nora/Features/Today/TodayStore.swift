import Foundation

@MainActor
@Observable
final class TodayStore {
    private(set) var state: TodayViewState = .loading
    var reflectionPrompt: ReflectionPrompt = ReflectionPrompts.random
    var hasAnsweredReflection = false

    private let briefService: BriefService
    private let savedInsightRepository: SavedInsightRepository
    private let topicRepository: TopicRepository

    init(environment: AppEnvironment) {
        self.briefService = environment.briefService
        self.savedInsightRepository = environment.savedInsightRepository
        self.topicRepository = environment.topicRepository
    }

    func load() async {
        state = .loading
        await refresh()
    }

    func refresh() async {
        do {
            let brief = try await briefService.fetchBrief(for: .now)
            state = .loaded(brief)
        } catch {
            state = .error
        }
    }

    func save(_ insight: Insight) {
        try? savedInsightRepository.save(insight)
        Haptics.play(.success)
    }

    func markUseful(_ insight: Insight) {
        Haptics.play(.light)
    }

    func markNotRelevant(_ insight: Insight) {
        Haptics.play(.light)
    }

    func muteTopic(_ insight: Insight) {
        Task {
            guard var topics = try? topicRepository.fetchAll() else { return }
            guard let index = topics.firstIndex(where: { $0.id == insight.topicId }) else { return }
            topics[index].notificationMode = .muted
            try? topicRepository.upsert(topics[index])
            Haptics.play(.medium)
        }
    }

    func submitReflection(_ answer: String) {
        hasAnsweredReflection = true
        Task {
            try? await briefService.submitReflection(question: reflectionPrompt.question, answer: answer)
        }
    }
}
