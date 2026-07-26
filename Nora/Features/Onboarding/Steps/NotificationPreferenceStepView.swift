import SwiftUI

struct NotificationPreferenceStepView: View {
    @Bindable var store: OnboardingStore
    let onNext: () -> Void
    let onBack: () -> Void

    var body: some View {
        OnboardingScaffold(
            progress: progressValue,
            title: "What should Nora notify you about right away?",
            subtitle: "Nora will respect this choice — you can change it anytime in Profile.",
            canGoBack: true,
            onBack: onBack,
            primaryTitle: "Continue",
            isPrimaryEnabled: true,
            onPrimary: onNext,
            onSkip: nil
        ) {
            VStack(spacing: Spacing.md) {
                ForEach(NotificationIntensity.allCases) { intensity in
                    OptionRow(
                        title: intensity.title,
                        subtitle: intensity.summary,
                        isSelected: store.notificationPreference == intensity
                    ) {
                        store.notificationPreference = intensity
                    }
                }
            }
        }
    }

    private var progressValue: Double {
        Double(OnboardingStep.notificationPreference.progressIndex) / Double(OnboardingStep.allCases.count - 1)
    }
}

private struct OptionRow: View {
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptics.play(.selection)
            action()
        }) {
            HStack(alignment: .top, spacing: Spacing.base) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(title)
                        .font(.noraCardTitle)
                        .foregroundStyle(Color.noraTextPrimary)
                    Text(subtitle)
                        .font(.noraSupporting)
                        .foregroundStyle(Color.noraTextSecondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.noraAccent : Color.noraTextTertiary)
                    .font(.system(size: 20))
            }
            .padding(Spacing.base)
            .background(isSelected ? Color.noraAccentSoft : Color.noraSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    NotificationPreferenceStepView(store: OnboardingStore(environment: .preview(), onComplete: {}), onNext: {}, onBack: {})
}
