import Foundation

/// Drives the onboarding conversation: holds the in-progress answers,
/// advances between steps, and — on the final step — turns everything the
/// user shared into a `UserProfile` plus a starting set of `Topic`s.
@MainActor
@Observable
final class OnboardingStore {
    var step: OnboardingStep = .welcome

    // Work & interests
    var professionInput: String = ""
    let interestSuggestions = ["SwiftUI", "Liverpool FC", "Sci-fi movies", "Photography", "Cooking"]
    var selectedInterests: Set<String> = []

    // Investments / important topics
    let topicSuggestions = ["OCB", "Bank stocks", "Real estate", "Savings"]
    var selectedTopics: Set<String> = []
    var customTopicText: String = ""

    // Current plans
    let planSuggestions = ["Trip to Japan", "Buy a new car", "Learn a new skill", "Change jobs"]
    var selectedPlans: Set<String> = []
    var customPlanText: String = ""

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
        var interests = Array(selectedInterests)
        var goals = Array(selectedPlans)
        if !customPlanText.trimmingCharacters(in: .whitespaces).isEmpty {
            goals.append(customPlanText)
        }
        if !customTopicText.trimmingCharacters(in: .whitespaces).isEmpty {
            interests.append(customTopicText)
        }
        return UserProfile(
            displayName: "Anh",
            profession: professionInput.isEmpty ? nil : professionInput,
            interests: interests,
            goals: goals,
            notificationPreference: notificationPreference
        )
    }

    var generatedTopics: [Topic] {
        var topics: [Topic] = []
        for name in selectedTopics {
            topics.append(Topic(name: name, category: .investments, relationship: .holding))
        }
        for name in selectedInterests {
            topics.append(Topic(name: name, category: .other, relationship: .favorite))
        }
        for name in selectedPlans {
            topics.append(Topic(name: name, category: .travel, relationship: .planning))
        }
        return topics
    }

    var understandingSummary: String {
        var parts: [String] = []
        if let profession = professionInput.isEmpty ? nil : professionInput {
            parts.append(localization.string("You're a \(localizedList([profession]))"))
        }
        if !selectedInterests.isEmpty {
            parts.append(localization.string("interested in \(localizedList(Array(selectedInterests)))"))
        }
        if !selectedTopics.isEmpty {
            parts.append(localization.string("following \(localizedList(Array(selectedTopics)))"))
        }
        if !selectedPlans.isEmpty {
            parts.append(localization.string("planning \(localizedList(Array(selectedPlans)))"))
        }
        guard !parts.isEmpty else {
            return localization.string("Nora will learn more about you through your conversations.")
        }
        return parts.joined(separator: ", ") + "."
    }

    /// Localize each item (proper nouns pass through) and join for display.
    private func localizedList(_ items: [String]) -> String {
        items.map { localization.localized($0) }.joined(separator: ", ")
    }

    func finish() async {
        isSubmitting = true
        defer { isSubmitting = false }

        try? await environment.profileService.updateProfile(generatedProfile)
        try? environment.profileRepository.save(generatedProfile)
        for topic in generatedTopics {
            try? environment.topicRepository.upsert(topic)
        }
        onComplete()
    }
}
