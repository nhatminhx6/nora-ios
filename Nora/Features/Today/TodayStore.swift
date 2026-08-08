import Foundation

@MainActor
@Observable
final class TodayStore {
    private(set) var state: TodayViewState = .loading
    private(set) var pendingInsightIDs: Set<UUID> = []
    private var isPollingForContent = false

    var isPerformingAction: Bool { !pendingInsightIDs.isEmpty }

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
        do {
            let brief = try await briefService.fetchBrief(for: .now)
            state = .loaded(brief)
            if !hasContent(brief) {
                try? await topicService.prepareContent()
                beginPollingForContent()
            }
        } catch {
            state = .error
        }
    }

    func refresh() async {
        do {
            let brief = try await briefService.fetchBrief(for: .now)
            if hasContent(brief) {
                state = .loaded(brief)
            } else if case .loaded(let current) = state, hasContent(current) {
                // Keep displaying stale data while the backend prepares the
                // next brief. A temporary empty response must not blank Today.
                try? await topicService.prepareContent()
                beginPollingForContent()
            } else {
                state = .loaded(brief)
                try? await topicService.prepareContent()
                beginPollingForContent()
            }
        } catch {
            // Network refresh failures must not replace usable cached/stale
            // content already on screen.
            if case .loaded(let current) = state, hasContent(current) { return }
            state = .error
        }
    }

    private func hasContent(_ brief: Brief) -> Bool {
        !brief.importantInsights.isEmpty ||
            !brief.otherInsights.isEmpty ||
            !brief.upcomingItems.isEmpty
    }

    private func beginPollingForContent() {
        guard !isPollingForContent else { return }
        isPollingForContent = true

        Task { [weak self] in
            guard let self else { return }
            defer { isPollingForContent = false }

            // Poll in the background while Today remains fully usable. This
            // is bounded so a quiet backend never leaves a runaway task.
            for _ in 0..<20 {
                do {
                    try await Task.sleep(for: .seconds(3))
                } catch {
                    return
                }
                guard let brief = try? await briefService.fetchBrief(for: .now) else { continue }
                guard hasContent(brief) else { continue }
                state = .loaded(brief)
                return
            }
        }
    }

    func save(_ insight: Insight) {
        guard !pendingInsightIDs.contains(insight.id) else { return }
        pendingInsightIDs.insert(insight.id)
        Task {
            defer { pendingInsightIDs.remove(insight.id) }
            do {
                let willSave = !insight.isSaved
                try await topicService.updateInsight(id: insight.id, status: nil, isSaved: willSave, isUseful: nil)
                if willSave {
                    try savedInsightRepository.save(insight)
                    Haptics.play(.success)
                } else {
                    try savedInsightRepository.remove(id: insight.id)
                    Haptics.play(.light)
                }
                setSaved(willSave, for: insight.id)
            } catch {}
        }
    }

    private func setSaved(_ isSaved: Bool, for insightId: UUID) {
        guard case .loaded(var brief) = state else { return }

        if let index = brief.importantInsights.firstIndex(where: { $0.id == insightId }) {
            brief.importantInsights[index].isSaved = isSaved
        }
        if let index = brief.otherInsights.firstIndex(where: { $0.id == insightId }) {
            brief.otherInsights[index].isSaved = isSaved
        }

        state = .loaded(brief)
    }

    func markUseful(_ insight: Insight) {
        guard !pendingInsightIDs.contains(insight.id) else { return }
        pendingInsightIDs.insert(insight.id)
        Task {
            defer { pendingInsightIDs.remove(insight.id) }
            do {
                try await topicService.updateInsight(id: insight.id, status: "READ", isSaved: nil, isUseful: true)
                Haptics.play(.light)
            } catch {}
        }
    }

    func markNotRelevant(_ insight: Insight) {
        guard !pendingInsightIDs.contains(insight.id) else { return }
        pendingInsightIDs.insert(insight.id)
        Task {
            defer { pendingInsightIDs.remove(insight.id) }
            do {
                try await topicService.updateInsight(id: insight.id, status: "DISMISSED", isSaved: nil, isUseful: false)
                Haptics.play(.light)
                await refresh()
            } catch {}
        }
    }

    func muteTopic(_ insight: Insight) {
        guard !pendingInsightIDs.contains(insight.id) else { return }
        pendingInsightIDs.insert(insight.id)
        Task {
            defer { pendingInsightIDs.remove(insight.id) }
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
