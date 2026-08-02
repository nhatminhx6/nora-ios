import Foundation

/// Reads and writes the user's learned profile.
protocol ProfileService: Sendable {
    func fetchProfile() async throws -> UserProfile
    func updateProfile(_ profile: UserProfile) async throws
    func resetPersonalization() async throws
}

struct LiveProfileService: ProfileService {
    private let client: APIClient

    init(client: APIClient = APIClient()) { self.client = client }

    func fetchProfile() async throws -> UserProfile {
        let response: ProfileResponse = try await client.send("users/me")
        return response.model
    }

    func updateProfile(_ profile: UserProfile) async throws {
        let _: ProfileResponse = try await client.send(
            "users/me",
            method: "PATCH",
            body: UpdateProfileRequest(profile: profile)
        )
    }

    func resetPersonalization() async throws {
        let current = try await fetchProfile()
        let _: ProfileResponse = try await client.send(
            "users/me",
            method: "PATCH",
            body: UpdateProfileRequest(
                displayName: current.displayName,
                profession: nil,
                interests: [],
                goals: [],
                locations: [],
                notificationIntensity: current.notificationPreference.rawValue,
                dailyBriefTime: Self.timeString(current.dailyBriefTime)
            )
        )
    }

    private static func timeString(_ components: DateComponents) -> String {
        String(format: "%02d:%02d", components.hour ?? 0, components.minute ?? 0)
    }
}

private struct ProfileResponse: Decodable {
    let id: UUID
    let displayName: String
    let createdAt: Date
    let updatedAt: Date
    let notificationPrefs: NotificationPreferences
    let profileData: ProfileData

    var model: UserProfile {
        let values = notificationPrefs.dailyBriefTime?.split(separator: ":").compactMap { Int($0) } ?? []
        return UserProfile(
            id: id,
            displayName: displayName,
            profession: profileData.profession,
            interests: profileData.interests,
            goals: profileData.goals,
            locations: profileData.locations,
            notificationPreference: NotificationIntensity(rawValue: notificationPrefs.intensity ?? "") ?? .balanced,
            dailyBriefTime: DateComponents(hour: values.first, minute: values.dropFirst().first),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

private struct NotificationPreferences: Decodable {
    let intensity: String?
    let dailyBriefTime: String?
}

private struct ProfileData: Decodable {
    let profession: String?
    let interests: [String]
    let goals: [String]
    let locations: [String]

    private enum CodingKeys: String, CodingKey {
        case profession, interests, goals, locations
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        profession = try values.decodeIfPresent(String.self, forKey: .profession)
        interests = try values.decodeIfPresent([String].self, forKey: .interests) ?? []
        goals = try values.decodeIfPresent([String].self, forKey: .goals) ?? []
        locations = try values.decodeIfPresent([String].self, forKey: .locations) ?? []
    }
}

private struct UpdateProfileRequest: Encodable {
    let displayName: String
    let profession: String?
    let interests: [String]
    let goals: [String]
    let locations: [String]
    let notificationIntensity: String
    let dailyBriefTime: String

    init(
        displayName: String,
        profession: String?,
        interests: [String],
        goals: [String],
        locations: [String],
        notificationIntensity: String,
        dailyBriefTime: String
    ) {
        self.displayName = displayName
        self.profession = profession
        self.interests = interests
        self.goals = goals
        self.locations = locations
        self.notificationIntensity = notificationIntensity
        self.dailyBriefTime = dailyBriefTime
    }

    init(profile: UserProfile) {
        self.init(
            displayName: profile.displayName,
            profession: profile.profession,
            interests: profile.interests,
            goals: profile.goals,
            locations: profile.locations,
            notificationIntensity: profile.notificationPreference.rawValue,
            dailyBriefTime: String(format: "%02d:%02d", profile.dailyBriefTime.hour ?? 0, profile.dailyBriefTime.minute ?? 0)
        )
    }
}

/// In-memory mock so the app runs fully without a backend.
actor MockProfileService: ProfileService {
    private var profile: UserProfile

    init(seed: UserProfile = PreviewData.profile) {
        self.profile = seed
    }

    func fetchProfile() async throws -> UserProfile {
        try await Task.sleep(for: .milliseconds(200))
        return profile
    }

    func updateProfile(_ profile: UserProfile) async throws {
        var updated = profile
        updated.updatedAt = .now
        self.profile = updated
    }

    func resetPersonalization() async throws {
        profile = UserProfile(displayName: profile.displayName)
    }
}
