import Foundation
import SwiftData

/// SwiftData-backed storage for a followed topic. Kept separate from the
/// `Topic` domain struct so views and services never depend on SwiftData
/// directly — only `TopicRepository` bridges the two.
@Model
final class TopicEntity {
    @Attribute(.unique) var id: UUID
    var topicKey: String?
    var name: String
    var categoryRaw: String
    var relationshipRaw: String
    var priorityRaw: String
    var trackingRules: [String]
    var notificationModeRaw: String
    var statusRaw: String
    var relevanceReason: String?
    var refinements: [String]
    var createdAt: Date

    init(
        id: UUID,
        topicKey: String? = nil,
        name: String,
        categoryRaw: String,
        relationshipRaw: String,
        priorityRaw: String,
        trackingRules: [String],
        notificationModeRaw: String,
        statusRaw: String,
        relevanceReason: String?,
        refinements: [String] = [],
        createdAt: Date
    ) {
        self.id = id
        self.topicKey = topicKey
        self.name = name
        self.categoryRaw = categoryRaw
        self.relationshipRaw = relationshipRaw
        self.priorityRaw = priorityRaw
        self.trackingRules = trackingRules
        self.notificationModeRaw = notificationModeRaw
        self.statusRaw = statusRaw
        self.relevanceReason = relevanceReason
        self.refinements = refinements
        self.createdAt = createdAt
    }
}

extension TopicEntity {
    convenience init(topic: Topic) {
        self.init(
            id: topic.id,
            topicKey: topic.topicKey,
            name: topic.name,
            categoryRaw: topic.category.rawValue,
            relationshipRaw: topic.relationship.rawValue,
            priorityRaw: topic.priority.rawValue,
            trackingRules: topic.trackingRules,
            notificationModeRaw: topic.notificationMode.rawValue,
            statusRaw: topic.status.rawValue,
            relevanceReason: topic.relevanceReason,
            refinements: topic.refinements,
            createdAt: topic.createdAt
        )
    }

    func apply(_ topic: Topic) {
        name = topic.name
        topicKey = topic.topicKey
        categoryRaw = topic.category.rawValue
        relationshipRaw = topic.relationship.rawValue
        priorityRaw = topic.priority.rawValue
        trackingRules = topic.trackingRules
        notificationModeRaw = topic.notificationMode.rawValue
        statusRaw = topic.status.rawValue
        relevanceReason = topic.relevanceReason
        refinements = topic.refinements
    }

    func asDomainModel() -> Topic? {
        guard
            let category = TopicCategory(rawValue: categoryRaw),
            let relationship = TopicRelationship(rawValue: relationshipRaw),
            let priority = TopicPriority(rawValue: priorityRaw),
            let notificationMode = TopicNotificationMode(rawValue: notificationModeRaw),
            let status = TopicStatus(rawValue: statusRaw)
        else { return nil }

        return Topic(
            id: id,
            topicKey: topicKey,
            name: name,
            category: category,
            relationship: relationship,
            priority: priority,
            trackingRules: trackingRules,
            notificationMode: notificationMode,
            status: status,
            relevanceReason: relevanceReason,
            refinements: refinements,
            createdAt: createdAt
        )
    }
}
