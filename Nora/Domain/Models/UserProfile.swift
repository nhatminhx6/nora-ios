import Foundation

/// How much the user wants to be interrupted for a given topic or overall.
enum NotificationIntensity: String, Codable, CaseIterable, Identifiable, Hashable {
    case minimal
    case balanced
    case active

    var id: String { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .minimal: "Minimal"
        case .balanced: "Balanced"
        case .active: "Active"
        }
    }

    var summary: LocalizedStringResource {
        switch self {
        case .minimal: "Only the most important updates, saved for your daily brief."
        case .balanced: "Important updates as they happen, the rest in your brief."
        case .active: "Tell me as soon as something worth knowing shows up."
        }
    }
}

/// The learned understanding of who the user is. Built from onboarding
/// answers and refined through ongoing conversation — never a form the user
/// fills out in one sitting.
struct UserProfile: Identifiable, Codable, Equatable {
    var id: UUID
    var displayName: String
    var profession: String?
    var interests: [String]
    var goals: [String]
    var locations: [String]
    var notificationPreference: NotificationIntensity
    var dailyBriefTime: DateComponents
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        displayName: String,
        profession: String? = nil,
        interests: [String] = [],
        goals: [String] = [],
        locations: [String] = [],
        notificationPreference: NotificationIntensity = .balanced,
        dailyBriefTime: DateComponents = DateComponents(hour: 8, minute: 0),
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.displayName = displayName
        self.profession = profession
        self.interests = interests
        self.goals = goals
        self.locations = locations
        self.notificationPreference = notificationPreference
        self.dailyBriefTime = dailyBriefTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
