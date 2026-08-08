import Foundation

/// Drives the onboarding conversation: holds the in-progress answers,
/// advances between steps, and — on the final step — turns everything the
/// user shared into a `UserProfile` plus a starting set of `Topic`s.
@MainActor
@Observable
final class OnboardingStore {
    var step: OnboardingStep = .welcome

    private(set) var catalog: [TopicCatalogItem] = []
    var selectedTopicKeys: Set<String> = []
    var refinementText: [String: String] = [:]
    private(set) var isLoadingCatalog = false
    var catalogError: String?

    // Notification preference
    var notificationPreference: NotificationIntensity = .balanced

    var isSubmitting = false

    private let environment: AppEnvironment
    private let localization: LocalizationManager
    private let onComplete: () -> Void

    init(environment: AppEnvironment, onComplete: @escaping () -> Void) {
        self.environment = environment
        self.localization = environment.localization
        self.onComplete = onComplete
    }

    var canGoBack: Bool { step != .welcome }
    var selectedCatalogItems: [TopicCatalogItem] {
        catalog.filter { selectedTopicKeys.contains($0.key) }
    }

    func loadCatalog() async {
        guard catalog.isEmpty, !isLoadingCatalog else { return }
        isLoadingCatalog = true
        catalogError = nil
        defer { isLoadingCatalog = false }
        do {
            catalog = try await environment.topicService.fetchCatalog()
        } catch {
            catalogError = error.localizedDescription
        }
    }

    func toggleTopic(_ key: String) {
        if selectedTopicKeys.contains(key) {
            selectedTopicKeys.remove(key)
            refinementText[key] = nil
        } else {
            selectedTopicKeys.insert(key)
        }
    }

    func refinements(for key: String) -> [String] {
        (refinementText[key] ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    func goNext() {
        guard let next = OnboardingStep(rawValue: step.rawValue + 1) else { return }
        step = next
    }

    func goBack() {
        guard let previous = OnboardingStep(rawValue: step.rawValue - 1) else { return }
        step = previous
    }

    /// Skips straight to the review screen with whatever has been answered
    /// so far — onboarding never blocks the user from seeing value quickly.
    func skipToReview() {
        step = .review
    }

    var generatedProfile: UserProfile {
        return UserProfile(
            displayName: environment.authSession.session?.user.displayName ?? "",
            interests: selectedCatalogItems.map(\.name),
            notificationPreference: notificationPreference
        )
    }

    var generatedTopics: [Topic] {
        selectedCatalogItems.map { item in
            Topic(
                topicKey: item.key,
                name: item.name,
                category: item.category,
                relationship: item.category == .travel ? .planning : .favorite,
                refinements: refinements(for: item.key)
            )
        }
    }

    var understandingSummary: String {
        guard !selectedCatalogItems.isEmpty else {
            return localization.string("Nora will learn more about you through your conversations.")
        }
        let prefix = localization.string("Nora will prepare updates for")
        return "\(prefix) \(localizedList(selectedCatalogItems.map(\.name)))."
    }

    /// Localize each item (proper nouns pass through) and join for display.
    private func localizedList(_ items: [String]) -> String {
        items.map { localization.localized($0) }.joined(separator: ", ")
    }

    func finish() async {
        guard !isSubmitting else { return }
        isSubmitting = true

        let profile = generatedProfile
        let topics = generatedTopics

        // Onboarding is never blocked by backend availability. Persist what
        // we can locally, enter the app immediately, then sync best-effort.
        try? environment.profileRepository.save(profile)
        onComplete()
        isSubmitting = false

        Task {
            try? await environment.profileService.updateProfile(profile)
            for topic in topics {
                guard let key = topic.topicKey else { continue }
                try? await environment.topicService.addCatalogTopic(
                    key: key,
                    refinements: topic.refinements
                )
            }
            try? await environment.topicService.prepareContent()
        }
    }
}
 
