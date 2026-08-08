import Foundation

/// Reads and writes the user's learned profile.
protocol ProfileService: Sendable {
    func fetchProfile() async throws -> UserProfile
    func fetchOnboardingState() async throws -> OnboardingState
    func updateProfile(_ profile: UserProfile) async throws
    func resetPersonalization() async throws
}

struct OnboardingState: Sendable {
    let isCompleted: Bool
    let restartToken: String?
}

struct LiveProfileService: ProfileService {
    private let client: APIClient

    init(client: APIClient = APIClient()) { self.client = client }

    func fetchProfile() async throws -> UserProfile {
        let response: ProfileResponse = try await client.send("users/me")
        return response.model
    }

    func fetchOnboardingState() async throws -> OnboardingState {
        let response: ProfileResponse = try await client.send("users/me")
        return OnboardingState(
            isCompleted: response.profileData.onboardingCompleted,
            restartToken: response.profileData.onboardingRestartToken
        )
    }

    func updateProfile(_ profile: UserProfile) async throws {
        let _: ProfileResponse = try await client.send(
            "users/me",
            method: "PATCH",
            body: UpdateProfileRequest(profile: profile)
        )
    }

    func resetPersonalization() async throws {
        let _: ResetPersonalizationResponse = try await client.send("users/me/data", method: "DELETE")
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
    let onboardingCompleted: Bool
    let onboardingRestartToken: String?
    let profession: String?
    let interests: [String]
    let goals: [String]
    let locations: [String]

    private enum CodingKeys: String, CodingKey {
        case onboardingCompleted, onboardingRestartToken, profession, interests, goals, locations
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        onboardingCompleted = try values.decodeIfPresent(Bool.self, forKey: .onboardingCompleted) ?? false
        onboardingRestartToken = try values.decodeIfPresent(String.self, forKey: .onboardingRestartToken)
        profession = try values.decodeIfPresent(String.self, forKey: .profession)
        interests = try values.decodeIfPresent([String].self, forKey: .interests) ?? []
        goals = try values.decodeIfPresent([String].self, forKey: .goals) ?? []
        locations = try values.decodeIfPresent([String].self, forKey: .locations) ?? []
    }
}

private struct UpdateProfileRequest: Encodable {
    let onboardingCompleted: Bool
    let displayName: String
    let profession: String?
    let interests: [String]
    let goals: [String]
    let locations: [String]
    let notificationIntensity: String
    let dailyBriefTime: String

    init(
        onboardingCompleted: Bool = true,
        displayName: String,
        profession: String?,
        interests: [String],
        goals: [String],
        locations: [String],
        notificationIntensity: String,
        dailyBriefTime: String
    ) {
        self.onboardingCompleted = onboardingCompleted
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

private struct ResetPersonalizationResponse: Decodable {
    let onboardingRequired: Bool
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

    func fetchOnboardingState() async throws -> OnboardingState {
        OnboardingState(isCompleted: true, restartToken: nil)
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
