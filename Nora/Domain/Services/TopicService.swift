import Foundation

/// Manages the set of topics Nora is following on the user's behalf.
protocol TopicService: Sendable {
    func fetchTopics() async throws -> [Topic]
    func addTopic(_ topic: Topic) async throws
    func updateTopic(_ topic: Topic) async throws
    func deleteTopic(id: UUID) async throws
    /// Insights and upcoming activity tied specifically to one topic, shown
    /// on its detail screen.
    func fetchInsights(for topicId: UUID) async throws -> [Insight]
}

actor MockTopicService: TopicService {
    private var topics: [Topic]
    private var insights: [Insight]

    init(seed: [Topic] = PreviewData.allTopics, insightSeed: [Insight] = PreviewData.allInsights) {
        self.topics = seed
        self.insights = insightSeed
    }

    func fetchTopics() async throws -> [Topic] {
        try await Task.sleep(for: .milliseconds(250))
        return topics
    }

    func fetchInsights(for topicId: UUID) async throws -> [Insight] {
        try await Task.sleep(for: .milliseconds(200))
        return insights.filter { $0.topicId == topicId }
    }

    func addTopic(_ topic: Topic) async throws {
        topics.append(topic)
    }

    func updateTopic(_ topic: Topic) async throws {
        guard let index = topics.firstIndex(where: { $0.id == topic.id }) else { return }
        topics[index] = topic
    }

    func deleteTopic(id: UUID) async throws {
        topics.removeAll { $0.id == id }
    }
}
