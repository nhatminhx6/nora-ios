import Foundation

@MainActor
@Observable
final class SettingsStore {
    private(set) var profile: UserProfile?
    private(set) var isLoading = true

    private let profileService: ProfileService
    private let profileRepository: ProfileRepository
    private let notificationService: NotificationService

    init(environment: AppEnvironment) {
        self.profileService = environment.profileService
        self.profileRepository = environment.profileRepository
        self.notificationService = environment.notificationService
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        if let stored = try? profileRepository.fetch() {
            profile = stored
        } else {
            // Fall back to the service on a fresh install so Settings is
            // never empty before the user has edited their profile.
            profile = try? await profileService.fetchProfile()
        }
    }

    func updateIntensity(_ intensity: NotificationIntensity) {
        guard var profile else { return }
        profile.notificationPreference = intensity
        profile.updatedAt = .now
        self.profile = profile
        try? profileRepository.save(profile)
    }

    func updateDailyBriefTime(_ components: DateComponents) {
        guard var profile else { return }
        profile.dailyBriefTime = components
        profile.updatedAt = .now
        self.profile = profile
        try? profileRepository.save(profile)
        Task { try? await notificationService.scheduleDailyBrief(at: components) }
    }
}
