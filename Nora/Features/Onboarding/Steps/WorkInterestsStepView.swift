import SwiftUI

struct WorkInterestsStepView: View {
    @Bindable var store: OnboardingStore
    let onNext: () -> Void
    let onSkip: () -> Void

    var body: some View {
        OnboardingScaffold(
            progress: progressValue,
            title: "What do you do for work?",
            subtitle: "And the topics you care about — Nora will use these as a starting point.",
            canGoBack: false,
            onBack: {},
            primaryTitle: "Continue",
            isPrimaryEnabled: true,
            onPrimary: onNext,
            onSkip: onSkip
        ) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                TextField("For example: iOS Developer", text: $store.professionInput)
                    .textFieldStyle(.plain)
                    .font(.noraBody)
                    .noraInputFieldBackground()

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Topics you're interested in")
                        .font(.noraSupporting)
                        .foregroundStyle(Color.noraTextSecondary)

                    TextField("Add topics separated by commas", text: $store.customInterestText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.noraBody)
                        .lineLimit(2...4)
                        .noraInputFieldBackground()
                }
            }
        }
    }

    private var progressValue: Double {
        Double(OnboardingStep.workAndInterests.progressIndex) / Double(OnboardingStep.allCases.count - 1)
    }

}

#Preview {
    WorkInterestsStepView(store: OnboardingStore(environment: .preview(), onComplete: {}), onNext: {}, onSkip: {})
}
