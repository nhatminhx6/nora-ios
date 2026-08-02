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
    var selectedInterests: Set<String> = []
    var customInterestText: String = ""

    // Investments / important topics
    var selectedTopics: Set<String> = []
    var customTopicText: String = ""

    // Current plans
    var selectedPlans: Set<String> = []
    var customPlanText: String = ""

    // Notification preference
    var notificationPreference: NotificationIntensity = .balanced

    var isSubmitting = false
    var submissionError: String?

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
        interests.append(contentsOf: parsedCustomInterests)
        return UserProfile(
            displayName: environment.authSession.session?.user.displayName ?? "",
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
        for customInterest in parsedCustomInterests {
            topics.append(Topic(name: customInterest, category: .other, relationship: .favorite))
        }
        let customTopic = customTopicText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !customTopic.isEmpty {
            topics.append(Topic(name: customTopic, category: .investments, relationship: .holding))
        }
        for name in selectedPlans {
            topics.append(Topic(name: name, category: .travel, relationship: .planning))
        }
        return topics
    }

    private var parsedCustomInterests: [String] {
        customInterestText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
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
        guard !isSubmitting else { return }
        isSubmitting = true
        submissionError = nil
        defer { isSubmitting = false }

        do {
            try await environment.profileService.updateProfile(generatedProfile)
            try environment.profileRepository.save(generatedProfile)
            for topic in generatedTopics {
                try await environment.topicService.addTopic(topic)
            }
            onComplete()
        } catch {
            submissionError = error.localizedDescription
        }
    }
}
 
