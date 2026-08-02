import Foundation

@MainActor
@Observable
final class TodayStore {
    private(set) var state: TodayViewState = .loading

    private let briefService: BriefService
    private let savedInsightRepository: SavedInsightRepository
    private let topicRepository: TopicRepository
    private let topicService: TopicService

    init(environment: AppEnvironment) {
        self.briefService = environment.briefService
        self.savedInsightRepository = environment.savedInsightRepository
        self.topicRepository = environment.topicRepository
        self.topicService = environment.topicService
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
        Task {
            do {
                try await topicService.updateInsight(id: insight.id, status: nil, isSaved: true, isUseful: nil)
                try savedInsightRepository.save(insight)
                Haptics.play(.success)
            } catch {}
        }
    }

    func markUseful(_ insight: Insight) {
        Task {
            do {
                try await topicService.updateInsight(id: insight.id, status: "READ", isSaved: nil, isUseful: true)
                Haptics.play(.light)
            } catch {}
        }
    }

    func markNotRelevant(_ insight: Insight) {
        Task {
            do {
                try await topicService.updateInsight(id: insight.id, status: "DISMISSED", isSaved: nil, isUseful: false)
                Haptics.play(.light)
                await refresh()
            } catch {}
        }
    }

    func muteTopic(_ insight: Insight) {
        Task {
            do {
                var topics = try await topicService.fetchTopics()
                guard let index = topics.firstIndex(where: { $0.id == insight.topicId }) else { return }
                topics[index].notificationMode = .muted
                try await topicService.updateTopic(topics[index])
                try topicRepository.upsert(topics[index])
                Haptics.play(.medium)
            } catch {}
        }
    }

}
