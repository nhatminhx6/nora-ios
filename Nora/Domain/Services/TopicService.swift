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
    func updateInsight(id: UUID, status: String?, isSaved: Bool?, isUseful: Bool?) async throws
}

struct LiveTopicService: TopicService {
    private let client: APIClient

    init(client: APIClient = APIClient()) { self.client = client }

    func fetchTopics() async throws -> [Topic] {
        let response: [InterestResponse] = try await client.send("interests")
        return response.map(\.model)
    }

    func addTopic(_ topic: Topic) async throws {
        let _: InterestResponse = try await client.send(
            "interests",
            method: "POST",
            body: InterestRequest(topic: topic)
        )
    }

    func updateTopic(_ topic: Topic) async throws {
        let _: InterestResponse = try await client.send(
            "interests/\(topic.id.uuidString)",
            method: "PATCH",
            body: InterestRequest(topic: topic, includeStatus: true)
        )
    }

    func deleteTopic(id: UUID) async throws {
        let _: EmptyResponse = try await client.send("interests/\(id.uuidString)", method: "DELETE")
    }

    func fetchInsights(for topicId: UUID) async throws -> [Insight] {
        try await client.send("interests/\(topicId.uuidString)/insights")
    }

    func updateInsight(id: UUID, status: String?, isSaved: Bool?, isUseful: Bool?) async throws {
        let _: UserInsightResponse = try await client.send(
            "user-insights/\(id.uuidString)",
            method: "PATCH",
            body: UpdateInsightRequest(status: status, isSaved: isSaved, isUseful: isUseful)
        )
    }
}

private struct UpdateInsightRequest: Encodable {
    let status: String?
    let isSaved: Bool?
    let isUseful: Bool?
}

private struct UserInsightResponse: Decodable {
    let id: UUID
}

private struct InterestResponse: Decodable {
    let id: UUID
    let name: String
    let type: String
    let status: String
    let config: TopicConfig
    let createdAt: Date

    var model: Topic {
        Topic(
            id: id,
            name: name,
            category: config.category ?? Self.category(for: type),
            relationship: config.relationship ?? .learning,
            priority: config.priority ?? .standard,
            trackingRules: config.trackingRules,
            notificationMode: config.notificationMode ?? .dailyBrief,
            status: status == "PAUSED" ? .paused : .active,
            relevanceReason: config.relevanceReason,
            createdAt: createdAt
        )
    }

    private static func category(for type: String) -> TopicCategory {
        switch type {
        case "STOCK", "CRYPTO": .investments
        case "SPORTS_TEAM": .sports
        case "MOVIE": .entertainment
        case "PRODUCT": .purchases
        case "JOB", "TECHNOLOGY": .work
        default: .other
        }
    }
}

private struct TopicConfig: Codable {
    let category: TopicCategory?
    let relationship: TopicRelationship?
    let priority: TopicPriority?
    let trackingRules: [String]
    let notificationMode: TopicNotificationMode?
    let relevanceReason: String?

    init(topic: Topic) {
        category = topic.category
        relationship = topic.relationship
        priority = topic.priority
        trackingRules = topic.trackingRules
        notificationMode = topic.notificationMode
        relevanceReason = topic.relevanceReason
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        category = try values.decodeIfPresent(TopicCategory.self, forKey: .category)
        relationship = try values.decodeIfPresent(TopicRelationship.self, forKey: .relationship)
        priority = try values.decodeIfPresent(TopicPriority.self, forKey: .priority)
        trackingRules = try values.decodeIfPresent([String].self, forKey: .trackingRules) ?? []
        notificationMode = try values.decodeIfPresent(TopicNotificationMode.self, forKey: .notificationMode)
        relevanceReason = try values.decodeIfPresent(String.self, forKey: .relevanceReason)
    }
}

private struct InterestRequest: Encodable {
    let name: String
    let type: String
    let status: String?
    let config: TopicConfig

    init(topic: Topic, includeStatus: Bool = false) {
        name = topic.name
        type = Self.entityType(for: topic.category)
        status = includeStatus ? (topic.status == .active ? "ACTIVE" : "PAUSED") : nil
        config = TopicConfig(topic: topic)
    }

    private static func entityType(for category: TopicCategory) -> String {
        switch category {
        case .investments: "STOCK"
        case .sports: "SPORTS_TEAM"
        case .entertainment: "MOVIE"
        case .purchases: "PRODUCT"
        case .work: "JOB"
        default: "TOPIC"
        }
    }
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

    func updateInsight(id: UUID, status: String?, isSaved: Bool?, isUseful: Bool?) async throws {}
}
