import SwiftUI

/// Human-readable error presentation with a clear next step. Never surfaces
/// a raw technical error string to the user.
struct ErrorStateView: View {
    let title: String
    var supportingText: String?
    var retryTitle: String = "Try again"
    var onRetry: (() -> Void)?
    var secondaryTitle: String?
    var onSecondary: (() -> Void)?

    var body: some View {
        VStack(spacing: Spacing.base) {
            Image(systemName: "arrow.clockwise.circle")
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(Color.noraTextTertiary)

            VStack(spacing: Spacing.xs) {
                Text(content: title)
                    .font(.noraCardTitle)
                    .foregroundStyle(Color.noraTextPrimary)
                    .multilineTextAlignment(.center)

                if let supportingText {
                    Text(content: supportingText)
                        .font(.noraSupporting)
                        .foregroundStyle(Color.noraTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            VStack(spacing: Spacing.sm) {
                if let onRetry {
                    Button(action: onRetry) { Text(content: retryTitle) }
                        .buttonStyle(.noraPrimary)
                }
                if let secondaryTitle, let onSecondary {
                    Button(action: onSecondary) { Text(content: secondaryTitle) }
                        .buttonStyle(.noraTertiary)
                }
            }
            .padding(.top, Spacing.sm)
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ErrorStateView(
        title: "Today's brief could not be refreshed.",
        supportingText: "Check your connection and try again.",
        onRetry: {},
        secondaryTitle: "View last updated brief",
        onSecondary: {}
    )
}
