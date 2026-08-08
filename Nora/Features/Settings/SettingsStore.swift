import Foundation

@MainActor
@Observable
final class SettingsStore {
    private(set) var profile: UserProfile?
    private(set) var isLoading = true
    private var pendingSaveCount = 0
    var isSaving: Bool { pendingSaveCount > 0 }

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
        do {
            profile = try await profileService.fetchProfile()
            if let profile { try profileRepository.save(profile) }
        } catch {
            profile = nil
        }
    }

    func updateIntensity(_ intensity: NotificationIntensity) {
        guard var profile else { return }
        profile.notificationPreference = intensity
        profile.updatedAt = .now
        self.profile = profile
        persist(profile)
    }

    func updateDailyBriefTime(_ components: DateComponents) {
        guard var profile else { return }
        profile.dailyBriefTime = components
        profile.updatedAt = .now
        self.profile = profile
        persist(profile)
        Task { try? await notificationService.scheduleDailyBrief(at: components) }
    }

    private func persist(_ profile: UserProfile) {
        Task {
            pendingSaveCount += 1
            defer { pendingSaveCount -= 1 }
            do {
                try await profileService.updateProfile(profile)
                try profileRepository.save(profile)
            } catch {
                await load()
            }
        }
    }
}
