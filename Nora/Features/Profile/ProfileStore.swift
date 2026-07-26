import Foundation

@MainActor
@Observable
final class ProfileStore {
    private(set) var profile: UserProfile?
    private(set) var investmentTopics: [Topic] = []
    private(set) var isLoading = true

    private let profileService: ProfileService
    private let profileRepository: ProfileRepository
    private let topicRepository: TopicRepository
    private let localization: LocalizationManager

    init(environment: AppEnvironment) {
        self.profileService = environment.profileService
        self.profileRepository = environment.profileRepository
        self.topicRepository = environment.topicRepository
        self.localization = environment.localization
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        if let stored = try? profileRepository.fetch() {
            profile = stored
        } else {
            profile = try? await profileService.fetchProfile()
        }
        investmentTopics = ((try? topicRepository.fetchAll()) ?? []).filter { $0.category == .investments }
    }

    var understandingSummary: String {
        guard let profile else { return localization.string("Nora doesn't know enough about you yet.") }
        var parts: [String] = []
        if let profession = profile.profession {
            parts.append(localization.string("You're a \(localizedList([profession]))"))
        }
        if !profile.interests.isEmpty {
            parts.append(localization.string("interested in \(localizedList(profile.interests))"))
        }
        if !investmentTopics.isEmpty {
            parts.append(localization.string("following \(localizedList(investmentTopics.map(\.name)))"))
        }
        if !profile.goals.isEmpty {
            parts.append(localization.string("planning \(localizedList(profile.goals))"))
        }
        guard !parts.isEmpty else { return localization.string("Nora doesn't know enough about you yet.") }
        return parts.joined(separator: ", ") + "."
    }

    /// Per-item localized, comma-joined lists for the About rows so each
    /// entry translates (proper nouns pass through) rather than the whole
    /// joined string being treated as one untranslated key.
    var localizedInterests: String { localizedList(profile?.interests ?? []) }
    var localizedGoals: String { localizedList(profile?.goals ?? []) }
    var localizedInvestmentNames: String { localizedList(investmentTopics.map(\.name)) }

    /// Localize each item (proper nouns pass through) and join for display.
    private func localizedList(_ items: [String]) -> String {
        items.map { localization.localized($0) }.joined(separator: ", ")
    }

    func updateProfession(_ text: String) {
        guard var profile else { return }
        profile.profession = text.isEmpty ? nil : text
        save(profile)
    }

    func updateInterests(_ items: [String]) {
        guard var profile else { return }
        profile.interests = items
        save(profile)
    }

    func updateGoals(_ items: [String]) {
        guard var profile else { return }
        profile.goals = items
        save(profile)
    }

    func resetPersonalization() async {
        try? await profileService.resetPersonalization()
        try? profileRepository.deleteAll()
        await load()
        Haptics.play(.medium)
    }

    private func save(_ profile: UserProfile) {
        var updated = profile
        updated.updatedAt = .now
        self.profile = updated
        try? profileRepository.save(updated)
        Haptics.play(.light)
    }
}
