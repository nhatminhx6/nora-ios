import Foundation
import Testing
@testable import Nora

struct TopicTests {
    @Test func priorityOrderingSortsHighFirst() {
        let priorities: [TopicPriority] = [.low, .high, .standard]
        #expect(priorities.sorted() == [.high, .standard, .low])
    }

    @Test func topicRoundTripsThroughJSON() throws {
        let topic = Topic(name: "OCB", category: .investments, relationship: .holding)
        let data = try JSONEncoder().encode(topic)
        let decoded = try JSONDecoder().decode(Topic.self, from: data)
        #expect(decoded.id == topic.id)
        #expect(decoded.name == topic.name)
        #expect(decoded.category == .investments)
    }
}
