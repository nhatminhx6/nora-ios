import Foundation
import SwiftData

@Model
final class UserProfileEntity {
    @Attribute(.unique) var id: UUID
    var displayName: String
    var profession: String?
    var interests: [String]
    var goals: [String]
    var locations: [String]
    var notificationPreferenceRaw: String
    var dailyBriefHour: Int
    var dailyBriefMinute: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID,
        displayName: String,
        profession: String?,
        interests: [String],
        goals: [String],
        locations: [String],
        notificationPreferenceRaw: String,
        dailyBriefHour: Int,
        dailyBriefMinute: Int,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.displayName = displayName
        self.profession = profession
        self.interests = interests
        self.goals = goals
        self.locations = locations
        self.notificationPreferenceRaw = notificationPreferenceRaw
        self.dailyBriefHour = dailyBriefHour
        self.dailyBriefMinute = dailyBriefMinute
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension UserProfileEntity {
    convenience init(profile: UserProfile) {
        self.init(
            id: profile.id,
            displayName: profile.displayName,
            profession: profile.profession,
            interests: profile.interests,
            goals: profile.goals,
            locations: profile.locations,
            notificationPreferenceRaw: profile.notificationPreference.rawValue,
            dailyBriefHour: profile.dailyBriefTime.hour ?? 8,
            dailyBriefMinute: profile.dailyBriefTime.minute ?? 0,
            createdAt: profile.createdAt,
            updatedAt: profile.updatedAt
        )
    }

    func apply(_ profile: UserProfile) {
        displayName = profile.displayName
        profession = profile.profession
        interests = profile.interests
        goals = profile.goals
        locations = profile.locations
        notificationPreferenceRaw = profile.notificationPreference.rawValue
        dailyBriefHour = profile.dailyBriefTime.hour ?? 8
        dailyBriefMinute = profile.dailyBriefTime.minute ?? 0
        updatedAt = profile.updatedAt
    }

    func asDomainModel() -> UserProfile? {
        guard let preference = NotificationIntensity(rawValue: notificationPreferenceRaw) else { return nil }
        return UserProfile(
            id: id,
            displayName: displayName,
            profession: profession,
            interests: interests,
            goals: goals,
            locations: locations,
            notificationPreference: preference,
            dailyBriefTime: DateComponents(hour: dailyBriefHour, minute: dailyBriefMinute),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
