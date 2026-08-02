import Foundation

enum FollowingFilter: String, CaseIterable, Identifiable, Hashable {
    case all
    case active
    case paused

    var id: String { rawValue }

    // Semantic keys so the status filter "Active" doesn't collide with the
    // notification-intensity "Active", which needs a different translation.
    var title: LocalizedStringResource {
        switch self {
        case .all: LocalizedStringResource("filter.all", defaultValue: "All")
        case .active: LocalizedStringResource("filter.active", defaultValue: "Active")
        case .paused: LocalizedStringResource("filter.paused", defaultValue: "Paused")
        }
    }
}

/// A category with its matching topics, used to drive `Following`'s
/// sectioned list. A dedicated `Identifiable` type instead of a tuple keeps
/// `ForEach` usage straightforward.
struct TopicGroup: Identifiable {
    let category: TopicCategory
    let topics: [Topic]
    var id: TopicCategory { category }
}

@MainActor
@Observable
final class FollowingStore {
    private(set) var topics: [Topic] = []
    var searchText: String = ""
    var filter: FollowingFilter = .all
    private(set) var isLoading = true

    private let topicRepository: TopicRepository
    private let topicService: TopicService
    private(set) var errorMessage: String?

    init(environment: AppEnvironment) {
        self.topicRepository = environment.topicRepository
        self.topicService = environment.topicService
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            topics = try await topicService.fetchTopics()
            for topic in topics { try topicRepository.upsert(topic) }
            errorMessage = nil
        } catch {
            topics = []
            errorMessage = error.localizedDescription
        }
    }

    var groupedTopics: [TopicGroup] {
        let filtered = filteredTopics
        return TopicCategory.allCases.compactMap { category in
            let inCategory = filtered.filter { $0.category == category }
            guard !inCategory.isEmpty else { return nil }
            return TopicGroup(category: category, topics: inCategory.sorted { $0.priority < $1.priority })
        }
    }

    var isEmpty: Bool { topics.isEmpty }

    private var filteredTopics: [Topic] {
        topics
            .filter { filter == .all || $0.status == TopicStatus(rawValue: filter.rawValue) }
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    func togglePause(_ topic: Topic) {
        var updated = topic
        updated.status = topic.status == .active ? .paused : .active
        Task {
            do {
                try await topicService.updateTopic(updated)
                await load()
                Haptics.play(.light)
            } catch { errorMessage = error.localizedDescription }
        }
    }

    func delete(_ topic: Topic) {
        Task {
            do {
                try await topicService.deleteTopic(id: topic.id)
                try topicRepository.delete(id: topic.id)
                await load()
                Haptics.play(.medium)
            } catch { errorMessage = error.localizedDescription }
        }
    }

    func addTopic(name: String, category: TopicCategory, relationship: TopicRelationship) {
        let topic = Topic(name: name, category: category, relationship: relationship)
        Task {
            do {
                try await topicService.addTopic(topic)
                await load()
                Haptics.play(.success)
            } catch { errorMessage = error.localizedDescription }
        }
    }
}
