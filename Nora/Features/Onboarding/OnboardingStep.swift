import Foundation

/// The ordered steps of the conversational onboarding flow. Each step asks
/// exactly one question.
enum OnboardingStep: Int, CaseIterable, Hashable {
    case welcome
    case workAndInterests
    case investments
    case notificationPreference
    case review

    var progressIndex: Int { rawValue }

    /// Steps counted toward the progress indicator (Welcome isn't a
    /// "question", so it's excluded).
    static var questionSteps: [OnboardingStep] {
        allCases.filter { $0 != .welcome }
    }
}
