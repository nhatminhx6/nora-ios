import SwiftUI

/// The urgency/nature of an insight — drives the visual treatment of the
/// insight component without ever showing the user a raw numeric score.
enum InsightType: String, Codable, CaseIterable, Hashable {
    case informational
    case important
    case actionRequired
    case upcoming
    case resolved

    var label: LocalizedStringResource {
        switch self {
        case .informational: "Worth knowing"
        case .important: "Needs attention"
        case .actionRequired: "Action required"
        case .upcoming: "Upcoming"
        case .resolved: "Resolved"
        }
    }

    var tintColor: Color {
        switch self {
        case .informational, .upcoming: .noraTextSecondary
        case .important, .actionRequired: .noraWarning
        case .resolved: .noraPositive
        }
    }

    var symbolName: String {
        switch self {
        case .informational: "info.circle"
        case .important: "exclamationmark.circle"
        case .actionRequired: "exclamationmark.triangle"
        case .upcoming: "clock"
        case .resolved: "checkmark.circle"
        }
    }
}

/// A single piece of surfaced information tied to a followed topic.
struct Insight: Identifiable, Codable, Equatable {
    var id: UUID
    var topicId: UUID
    var topicName: String
    var category: TopicCategory
    var type: InsightType
    var title: String
    var summary: String
    var relevanceReason: String
    var suggestedAction: String?
    var sourceCount: Int
    var publishedAt: Date
    var eventDate: Date?
    var isRead: Bool
    var isSaved: Bool

    init(
        id: UUID = UUID(),
        topicId: UUID,
        topicName: String,
        category: TopicCategory,
        type: InsightType,
        title: String,
        summary: String,
        relevanceReason: String,
        suggestedAction: String? = nil,
        sourceCount: Int = 1,
        publishedAt: Date = .now,
        eventDate: Date? = nil,
        isRead: Bool = false,
        isSaved: Bool = false
    ) {
        self.id = id
        self.topicId = topicId
        self.topicName = topicName
        self.category = category
        self.type = type
        self.title = title
        self.summary = summary
        self.relevanceReason = relevanceReason
        self.suggestedAction = suggestedAction
        self.sourceCount = sourceCount
        self.publishedAt = publishedAt
        self.eventDate = eventDate
        self.isRead = isRead
        self.isSaved = isSaved
    }
}
