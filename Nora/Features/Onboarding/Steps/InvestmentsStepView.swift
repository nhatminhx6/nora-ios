import SwiftUI

struct InvestmentsStepView: View {
    @Bindable var store: OnboardingStore
    let onNext: () -> Void
    let onBack: () -> Void
    let onSkip: () -> Void

    var body: some View {
        OnboardingScaffold(
            progress: progressValue,
            title: "What are you investing in or keeping an eye on?",
            subtitle: "Nora will track earnings, prices, and related news.",
            canGoBack: true,
            onBack: onBack,
            primaryTitle: "Continue",
            isPrimaryEnabled: true,
            onPrimary: onNext,
            onSkip: onSkip
        ) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                TextField("Type an investment or asset name", text: $store.customTopicText)
                    .textFieldStyle(.plain)
                    .font(.noraBody)
                    .noraInputFieldBackground()
            }
        }
    }

    private var progressValue: Double {
        Double(OnboardingStep.investments.progressIndex) / Double(OnboardingStep.allCases.count - 1)
    }

}

#Preview {
    InvestmentsStepView(store: OnboardingStore(environment: .preview(), onComplete: {}), onNext: {}, onBack: {}, onSkip: {})
}
