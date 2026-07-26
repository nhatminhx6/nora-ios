import SwiftUI

/// Shared chrome for every onboarding question screen: a thin progress
/// indicator, a title, free-form content, and a footer with primary/back/
/// skip actions. Keeps each step view focused only on its own question.
struct OnboardingScaffold<Content: View>: View {
    let progress: Double
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey?
    let canGoBack: Bool
    let onBack: () -> Void
    let primaryTitle: LocalizedStringKey
    let isPrimaryEnabled: Bool
    let onPrimary: () -> Void
    var onSkip: (() -> Void)?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(title)
                            .font(.noraLargeTitle)
                            .foregroundStyle(Color.noraTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        if let subtitle {
                            Text(subtitle)
                                .font(.noraBody)
                                .foregroundStyle(Color.noraTextSecondary)
                        }
                    }
                    .padding(.top, Spacing.lg)

                    content
                }
                .noraScreenPadding()
                .padding(.bottom, Spacing.xl)
            }

            footer
        }
        .noraScreenBackground()
    }

    private var header: some View {
        HStack(spacing: Spacing.base) {
            if canGoBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.noraTextPrimary)
                        .frame(width: TouchTarget.minimum, height: TouchTarget.minimum)
                }
                .accessibilityLabel("Back")
            } else {
                Spacer().frame(width: TouchTarget.minimum)
            }

            ProgressView(value: progress)
                .tint(Color.noraAccent)

            if let onSkip {
                Button("Skip", action: onSkip)
                    .buttonStyle(.noraTertiary)
                    .font(.noraSupporting.weight(.medium))
            } else {
                Spacer().frame(width: TouchTarget.minimum)
            }
        }
        .padding(.horizontal, Spacing.base)
        .padding(.top, Spacing.sm)
    }

    private var footer: some View {
        VStack {
            Button(primaryTitle, action: onPrimary)
                .buttonStyle(.noraPrimary)
                .disabled(!isPrimaryEnabled)
                .opacity(isPrimaryEnabled ? 1 : 0.5)
        }
        .noraScreenPadding()
        .padding(.bottom, Spacing.sm)
    }
}
