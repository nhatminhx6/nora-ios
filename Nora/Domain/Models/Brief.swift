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
    var filters: [BriefFilter]
    var groups: [BriefCategoryGroup]
    var selectedCategory: String
    var pagination: BriefPagination

    init(
        id: UUID = UUID(),
        date: Date,
        headline: String,
        importantInsights: [Insight] = [],
        otherInsights: [Insight] = [],
        upcomingItems: [UpcomingItem] = [],
        filters: [BriefFilter] = [],
        groups: [BriefCategoryGroup] = [],
        selectedCategory: String = "all",
        pagination: BriefPagination = .empty
    ) {
        self.id = id
        self.date = date
        self.headline = headline
        self.importantInsights = importantInsights
        self.otherInsights = otherInsights
        self.upcomingItems = upcomingItems
        self.filters = filters
        self.groups = groups
        self.selectedCategory = selectedCategory
        self.pagination = pagination
    }

    private enum CodingKeys: String, CodingKey {
        case id, date, headline, importantInsights, otherInsights, upcomingItems, filters, groups
        case selectedCategory, pagination
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        date = try values.decode(Date.self, forKey: .date)
        headline = try values.decode(String.self, forKey: .headline)
        importantInsights = try values.decodeIfPresent([Insight].self, forKey: .importantInsights) ?? []
        otherInsights = try values.decodeIfPresent([Insight].self, forKey: .otherInsights) ?? []
        upcomingItems = try values.decodeIfPresent([UpcomingItem].self, forKey: .upcomingItems) ?? []
        filters = try values.decodeIfPresent([BriefFilter].self, forKey: .filters) ?? []
        groups = try values.decodeIfPresent([BriefCategoryGroup].self, forKey: .groups) ?? []
        selectedCategory = try values.decodeIfPresent(String.self, forKey: .selectedCategory) ?? "all"
        pagination = try values.decodeIfPresent(BriefPagination.self, forKey: .pagination) ?? .empty
    }
}

struct BriefPagination: Codable, Equatable {
    var page: Int
    var pageSize: Int
    var total: Int
    var totalPages: Int
    var hasNextPage: Bool

    static let empty = BriefPagination(page: 1, pageSize: 20, total: 0, totalPages: 0, hasNextPage: false)
}

struct BriefFilter: Identifiable, Codable, Equatable {
    var key: String
    var title: String
    var count: Int

    var id: String { key }
}

struct BriefCategoryGroup: Identifiable, Codable, Equatable {
    var key: String
    var title: String
    var count: Int
    var importantInsights: [Insight]
    var otherInsights: [Insight]
    var upcomingItems: [UpcomingItem]

    var id: String { key }
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
