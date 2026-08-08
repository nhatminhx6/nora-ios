import SwiftUI

struct ReviewStepView: View {
    let store: OnboardingStore
    let onBack: () -> Void
    let onFinish: () -> Void

    var body: some View {
        OnboardingScaffold(
            progress: 1,
            title: "Here's what Nora understands",
            subtitle: "You can adjust this anytime in Profile.",
            canGoBack: true,
            onBack: onBack,
            primaryTitle: store.isSubmitting ? "Setting up…" : "Start using Nora",
            isPrimaryEnabled: !store.isSubmitting,
            isPrimaryLoading: store.isSubmitting,
            onPrimary: onFinish,
            onSkip: nil
        ) {
            VStack(alignment: .leading, spacing: Spacing.base) {
                Text(store.understandingSummary)
                    .font(.noraBody)
                    .foregroundStyle(Color.noraTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .noraSurfaceCard()

                HStack(spacing: 4) {
                    Text("Notification:")
                    Text(store.notificationPreference.title)
                }
                .font(.noraSupporting)
                .foregroundStyle(Color.noraTextSecondary)

            }
        }
    }
}

#Preview {
    ReviewStepView(store: OnboardingStore(environment: .preview(), onComplete: {}), onBack: {}, onFinish: {})
}
