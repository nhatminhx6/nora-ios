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
                FlowLayout(spacing: Spacing.sm) {
                    ForEach(store.planSuggestions, id: \.self) { suggestion in
                        ChipView(
                            title: suggestion,
                            isSelected: store.selectedPlans.contains(suggestion)
                        ) {
                            toggle(suggestion)
                        }
                    }
                }

                TextField("Or describe your plan", text: $store.customPlanText, axis: .vertical)
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

    private func toggle(_ value: String) {
        if store.selectedPlans.contains(value) {
            store.selectedPlans.remove(value)
        } else {
            store.selectedPlans.insert(value)
        }
    }
}

#Preview {
    PlansStepView(store: OnboardingStore(environment: .preview(), onComplete: {}), onNext: {}, onBack: {}, onSkip: {})
}
