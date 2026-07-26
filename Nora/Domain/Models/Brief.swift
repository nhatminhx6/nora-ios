import Foundation

/// The Today screen's core payload for a given date: a headline summary
/// plus the insights and upcoming items worth surfacing.
struct Brief: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var headline: String
    var importantInsights: [Insight]
    var otherInsights: [Insight]
    var upcomingItems: [UpcomingItem]

    init(
        id: UUID = UUID(),
        date: Date,
        headline: String,
        importantInsights: [Insight] = [],
        otherInsights: [Insight] = [],
        upcomingItems: [UpcomingItem] = []
    ) {
        self.id = id
        self.date = date
        self.headline = headline
        self.importantInsights = importantInsights
        self.otherInsights = otherInsights
        self.upcomingItems = upcomingItems
    }
}

/// A dated event, deadline, or release surfaced in the Upcoming section.
struct UpcomingItem: Identifiable, Codable, Equatable {
    var id: UUID
    var topicName: String
    var category: TopicCategory
    var title: String
    var date: Date

    init(
        id: UUID = UUID(),
        topicName: String,
        category: TopicCategory,
        title: String,
        date: Date
    ) {
        self.id = id
        self.topicName = topicName
        self.category = category
        self.title = title
        self.date = date
    }
}
