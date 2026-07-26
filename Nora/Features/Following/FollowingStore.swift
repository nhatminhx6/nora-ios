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

    init(environment: AppEnvironment) {
        self.topicRepository = environment.topicRepository
    }

    func load() {
        isLoading = true
        defer { isLoading = false }
        topics = (try? topicRepository.fetchAll()) ?? []
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
        try? topicRepository.upsert(updated)
        load()
        Haptics.play(.light)
    }

    func delete(_ topic: Topic) {
        try? topicRepository.delete(id: topic.id)
        load()
        Haptics.play(.medium)
    }

    func addTopic(name: String, category: TopicCategory, relationship: TopicRelationship) {
        let topic = Topic(name: name, category: category, relationship: relationship)
        try? topicRepository.upsert(topic)
        load()
        Haptics.play(.success)
    }
}
