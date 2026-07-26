import Foundation
import SwiftData

/// Persists insights the user explicitly saved from the Today or Topic
/// Detail screens so they survive app restarts.
@Model
final class SavedInsightEntity {
    @Attribute(.unique) var id: UUID
    var topicId: UUID
    var topicName: String
    var categoryRaw: String
    var typeRaw: String
    var title: String
    var summary: String
    var relevanceReason: String
    var suggestedAction: String?
    var sourceCount: Int
    var publishedAt: Date
    var eventDate: Date?
    var savedAt: Date

    init(
        id: UUID,
        topicId: UUID,
        topicName: String,
        categoryRaw: String,
        typeRaw: String,
        title: String,
        summary: String,
        relevanceReason: String,
        suggestedAction: String?,
        sourceCount: Int,
        publishedAt: Date,
        eventDate: Date?,
        savedAt: Date
    ) {
        self.id = id
        self.topicId = topicId
        self.topicName = topicName
        self.categoryRaw = categoryRaw
        self.typeRaw = typeRaw
        self.title = title
        self.summary = summary
        self.relevanceReason = relevanceReason
        self.suggestedAction = suggestedAction
        self.sourceCount = sourceCount
        self.publishedAt = publishedAt
        self.eventDate = eventDate
        self.savedAt = savedAt
    }
}

extension SavedInsightEntity {
    convenience init(insight: Insight, savedAt: Date = .now) {
        self.init(
            id: insight.id,
            topicId: insight.topicId,
            topicName: insight.topicName,
            categoryRaw: insight.category.rawValue,
            typeRaw: insight.type.rawValue,
            title: insight.title,
            summary: insight.summary,
            relevanceReason: insight.relevanceReason,
            suggestedAction: insight.suggestedAction,
            sourceCount: insight.sourceCount,
            publishedAt: insight.publishedAt,
            eventDate: insight.eventDate,
            savedAt: savedAt
        )
    }

    func asDomainModel() -> Insight? {
        guard
            let category = TopicCategory(rawValue: categoryRaw),
            let type = InsightType(rawValue: typeRaw)
        else { return nil }

        return Insight(
            id: id,
            topicId: topicId,
            topicName: topicName,
            category: category,
            type: type,
            title: title,
            summary: summary,
            relevanceReason: relevanceReason,
            suggestedAction: suggestedAction,
            sourceCount: sourceCount,
            publishedAt: publishedAt,
            eventDate: eventDate,
            isRead: true,
            isSaved: true
        )
    }
}
