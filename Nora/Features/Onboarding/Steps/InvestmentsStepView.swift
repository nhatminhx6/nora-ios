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
                FlowLayout(spacing: Spacing.sm) {
                    ForEach(store.topicSuggestions, id: \.self) { suggestion in
                        ChipView(
                            title: suggestion,
                            isSelected: store.selectedTopics.contains(suggestion)
                        ) {
                            toggle(suggestion)
                        }
                    }
                }

                TextField("Or type another name, e.g. OCB", text: $store.customTopicText)
                    .textFieldStyle(.plain)
                    .font(.noraBody)
                    .noraInputFieldBackground()
            }
        }
    }

    private var progressValue: Double {
        Double(OnboardingStep.investments.progressIndex) / Double(OnboardingStep.allCases.count - 1)
    }

    private func toggle(_ value: String) {
        if store.selectedTopics.contains(value) {
            store.selectedTopics.remove(value)
        } else {
            store.selectedTopics.insert(value)
        }
    }
}

#Preview {
    InvestmentsStepView(store: OnboardingStore(environment: .preview(), onComplete: {}), onNext: {}, onBack: {}, onSkip: {})
}
