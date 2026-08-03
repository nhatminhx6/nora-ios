import Foundation

/// Manages the set of topics Nora is following on the user's behalf.
protocol TopicService: Sendable {
    func fetchCatalog() async throws -> [TopicCatalogItem]
    func fetchTopics() async throws -> [Topic]
    func addCatalogTopic(key: String, refinements: [String]) async throws
    func prepareContent() async throws
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

    func fetchCatalog() async throws -> [TopicCatalogItem] {
        try await client.send("interests/catalog")
    }

    func fetchTopics() async throws -> [Topic] {
        let response: [InterestResponse] = try await client.send("interests")
        return response.map(\.model)
    }

    func addTopic(_ topic: Topic) async throws {
        guard let topicKey = topic.topicKey else {
            throw APIClientError.server("Choose a topic from Nora's catalog.")
        }
        try await addCatalogTopic(key: topicKey, refinements: topic.refinements)
    }

    func addCatalogTopic(key: String, refinements: [String]) async throws {
        let _: InterestResponse = try await client.send(
            "interests",
            method: "POST",
            body: CreateCatalogInterestRequest(topicKey: key, refinements: refinements)
        )
    }

    func prepareContent() async throws {
        let _: ContentPreparationResponse = try await client.send(
            "ingestion/sync",
            method: "POST",
            timeoutInterval: 180
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
    let topicKey: String?
    let name: String
    let type: String
    let status: String
    let config: TopicConfig
    let createdAt: Date

    var model: Topic {
        Topic(
            id: id,
            topicKey: topicKey,
            name: name,
            category: config.category ?? Self.category(for: type),
            relationship: config.relationship ?? .learning,
            priority: config.priority ?? .standard,
            trackingRules: config.trackingRules,
            notificationMode: config.notificationMode ?? .dailyBrief,
            status: status == "PAUSED" ? .paused : .active,
            relevanceReason: config.relevanceReason,
            refinements: config.refinements,
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
    let refinements: [String]

    init(topic: Topic) {
        category = topic.category
        relationship = topic.relationship
        priority = topic.priority
        trackingRules = topic.trackingRules
        notificationMode = topic.notificationMode
        relevanceReason = topic.relevanceReason
        refinements = topic.refinements
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        category = try values.decodeIfPresent(TopicCategory.self, forKey: .category)
        relationship = try values.decodeIfPresent(TopicRelationship.self, forKey: .relationship)
        priority = try values.decodeIfPresent(TopicPriority.self, forKey: .priority)
        trackingRules = try values.decodeIfPresent([String].self, forKey: .trackingRules) ?? []
        notificationMode = try values.decodeIfPresent(TopicNotificationMode.self, forKey: .notificationMode)
        relevanceReason = try values.decodeIfPresent(String.self, forKey: .relevanceReason)
        refinements = try values.decodeIfPresent([String].self, forKey: .refinements) ?? []
    }
}

private struct CreateCatalogInterestRequest: Encodable {
    let topicKey: String
    let refinements: [String]
}

private struct ContentPreparationResponse: Decodable {
    let interests: Int
    let events: Int
    let insights: Int
    let briefId: String?
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

    func fetchCatalog() async throws -> [TopicCatalogItem] {
        [
            TopicCatalogItem(key: "travel", name: "Du lịch", description: "Điểm đến, visa, thời tiết và thay đổi hành trình.", category: .travel, symbol: "airplane", refinementLabel: "Địa điểm anh quan tâm", refinementPlaceholder: "Cửu Trại Câu, Thành Đô"),
            TopicCatalogItem(key: "technology", name: "Công nghệ", description: "Sản phẩm, nền tảng và thay đổi kỹ thuật đáng chú ý.", category: .work, symbol: "cpu", refinementLabel: "Công nghệ cụ thể", refinementPlaceholder: "SwiftUI, iOS, OpenAI"),
        ]
    }

    func addCatalogTopic(key: String, refinements: [String]) async throws {
        topics.append(Topic(topicKey: key, name: key, category: .other, relationship: .favorite, refinements: refinements))
    }

    func prepareContent() async throws {}

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
