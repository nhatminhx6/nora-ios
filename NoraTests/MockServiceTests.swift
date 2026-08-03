import Testing
@testable import Nora

struct MockServiceTests {
    @Test func briefServiceReturnsSeedData() async throws {
        let service = MockBriefService()
        let brief = try await service.fetchBrief(for: .now)
        #expect(!brief.headline.isEmpty)
    }

    @Test func topicServiceAddAndFetchRoundTrips() async throws {
        let service = MockTopicService(seed: [], insightSeed: [])
        let topic = Topic(
            topicKey: "technology",
            name: "Technology",
            category: .technology,
            relationship: .learning,
            refinements: ["SwiftUI"]
        )
        try await service.addTopic(topic)
        let fetched = try await service.fetchTopics()
        #expect(fetched.contains { $0.id == topic.id })
    }

    @Test func assistantServiceRecognizesPurchaseIntent() async throws {
        let service = MockAssistantService()
        let reply = try await service.send(message: "Tôi đang cân nhắc mua Mazda CX-5", history: [])
        #expect(reply.extractedContext?.followUpQuestion != nil)
    }
}
