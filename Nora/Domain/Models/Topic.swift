import Foundation

/// Grouping used across Following and Profile. Order here defines display
/// order when multiple categories are present.
enum TopicCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case investments
    case work
    case sports
    case entertainment
    case travel
    case purchases
    case health
    case other

    var id: String { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .investments: "Investments"
        case .work: "Work"
        case .sports: "Sports"
        case .entertainment: "Entertainment"
        case .travel: "Travel"
        case .purchases: "Purchases"
        case .health: "Health"
        case .other: "Other"
        }
    }

    var symbolName: String {
        switch self {
        case .investments: "chart.line.uptrend.xyaxis"
        case .work: "briefcase"
        case .sports: "sportscourt"
        case .entertainment: "film"
        case .travel: "airplane"
        case .purchases: "bag"
        case .health: "heart"
        case .other: "sparkle"
        }
    }
}

/// The user's relationship to a topic — why they're following it.
enum TopicRelationship: String, Codable, CaseIterable, Identifiable, Hashable {
    case holding
    case learning
    case considering
    case favorite
    case planning

    var id: String { rawValue }

    var label: LocalizedStringResource {
        switch self {
        case .holding: "Holding"
        case .learning: "Learning"
        case .considering: "Considering"
        case .favorite: "Favorite"
        case .planning: "Planning"
        }
    }
}

enum TopicPriority: String, Codable, CaseIterable, Identifiable, Hashable, Comparable {
    case low
    case standard
    case high

    var id: String { rawValue }

    var label: LocalizedStringResource {
        switch self {
        case .low: "Low priority"
        case .standard: "Standard"
        case .high: "High priority"
        }
    }

    private var sortOrder: Int {
        switch self {
        case .high: 0
        case .standard: 1
        case .low: 2
        }
    }

    static func < (lhs: TopicPriority, rhs: TopicPriority) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

enum TopicNotificationMode: String, Codable, CaseIterable, Identifiable, Hashable {
    case immediate
    case dailyBrief
    case muted

    var id: String { rawValue }

    var label: LocalizedStringResource {
        switch self {
        case .immediate: "Notify immediately"
        case .dailyBrief: "Include in daily brief"
        case .muted: "Muted"
        }
    }

    var symbolName: String {
        switch self {
        case .immediate: "bell.fill"
        case .dailyBrief: "sun.max"
        case .muted: "bell.slash"
        }
    }
}

enum TopicStatus: String, Codable, CaseIterable, Identifiable, Hashable {
    case active
    case paused

    var id: String { rawValue }
}

/// Something Nora is watching on the user's behalf.
struct Topic: Identifiable, Codable, Equatable {
    var id: UUID
    var topicKey: String?
    var name: String
    var category: TopicCategory
    var relationship: TopicRelationship
    var priority: TopicPriority
    /// Natural-language rules describing what to track, set either from
    /// onboarding defaults or the user's own words in the Assistant.
    var trackingRules: [String]
    var notificationMode: TopicNotificationMode
    var status: TopicStatus
    var relevanceReason: String?
    var refinements: [String]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        topicKey: String? = nil,
        name: String,
        category: TopicCategory,
        relationship: TopicRelationship,
        priority: TopicPriority = .standard,
        trackingRules: [String] = [],
        notificationMode: TopicNotificationMode = .dailyBrief,
        status: TopicStatus = .active,
        relevanceReason: String? = nil,
        refinements: [String] = [],
        createdAt: Date = .now
    ) {
        self.id = id
        self.topicKey = topicKey
        self.name = name
        self.category = category
        self.relationship = relationship
        self.priority = priority
        self.trackingRules = trackingRules
        self.notificationMode = notificationMode
        self.status = status
        self.relevanceReason = relevanceReason
        self.refinements = refinements
        self.createdAt = createdAt
    }
}
