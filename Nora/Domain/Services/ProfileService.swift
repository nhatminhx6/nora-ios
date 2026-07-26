import Foundation

/// Reads and writes the user's learned profile.
protocol ProfileService: Sendable {
    func fetchProfile() async throws -> UserProfile
    func updateProfile(_ profile: UserProfile) async throws
    func resetPersonalization() async throws
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
