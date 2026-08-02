import SwiftUI

struct PlansStepView: View {
    @Bindable var store: OnboardingStore
    let onNext: () -> Void
    let onBack: () -> Void
    let onSkip: () -> Void

    var body: some View {
        OnboardingScaffold(
            progress: progressValue,
            title: "Any big plans coming up?",
            subtitle: "A trip, a purchase, or a goal on the horizon.",
            canGoBack: true,
            onBack: onBack,
            primaryTitle: "Continue",
            isPrimaryEnabled: true,
            onPrimary: onNext,
            onSkip: onSkip
        ) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                TextField("Describe your plan", text: $store.customPlanText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.noraBody)
                    .lineLimit(2...4)
                    .noraInputFieldBackground()
            }
        }
    }

    private var progressValue: Double {
        Double(OnboardingStep.plans.progressIndex) / Double(OnboardingStep.allCases.count - 1)
    }

}

#Preview {
    PlansStepView(store: OnboardingStore(environment: .preview(), onComplete: {}), onNext: {}, onBack: {}, onSkip: {})
}
