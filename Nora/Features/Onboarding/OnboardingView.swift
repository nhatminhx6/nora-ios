import SwiftUI

/// Top-level onboarding container. Presents one question per screen with a
/// gentle slide/fade transition between steps, rather than a paged form.
struct OnboardingView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var store: OnboardingStore?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let onComplete: () -> Void

    var body: some View {
        Group {
            if let store {
                content(for: store)
            } else {
                Color.noraBackground
            }
        }
        .task {
            if store == nil {
                store = OnboardingStore(environment: environment, onComplete: onComplete)
            }
        }
    }

    @ViewBuilder
    private func content(for store: OnboardingStore) -> some View {
        Group {
            switch store.step {
            case .welcome:
                WelcomeStepView(onStart: { advance(store) })
            case .workAndInterests:
                WorkInterestsStepView(store: store, onNext: { advance(store) }, onSkip: { store.skipToReview() })
            case .investments:
                InvestmentsStepView(store: store, onNext: { advance(store) }, onBack: { retreat(store) }, onSkip: { store.skipToReview() })
            case .plans:
                PlansStepView(store: store, onNext: { advance(store) }, onBack: { retreat(store) }, onSkip: { store.skipToReview() })
            case .notificationPreference:
                NotificationPreferenceStepView(store: store, onNext: { advance(store) }, onBack: { retreat(store) })
            case .review:
                ReviewStepView(store: store, onBack: { retreat(store) }, onFinish: {
                    Task { await store.finish() }
                })
            }
        }
        .transition(reduceMotion ? .opacity : .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .id(store.step)
    }

    private func advance(_ store: OnboardingStore) {
        Haptics.play(.light)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            store.goNext()
        }
    }

    private func retreat(_ store: OnboardingStore) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            store.goBack()
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
        .environment(AppEnvironment.preview())
}
