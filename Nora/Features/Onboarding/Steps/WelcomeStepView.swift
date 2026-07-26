import SwiftUI

/// The very first screen. No robot illustration, no account wall — just
/// the promise of the app and a way to start talking to it.
struct WelcomeStepView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            VStack(spacing: Spacing.base) {
                Image(systemName: "circle.hexagongrid")
                    .font(.system(size: 40, weight: .regular))
                    .foregroundStyle(Color.noraAccent)

                VStack(spacing: Spacing.sm) {
                    Text("A personal brief built around your life.")
                        .font(.noraLargeTitle)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.noraTextPrimary)

                    Text("Nora learns what matters to you, follows it, and only speaks up when something is worth your attention.")
                        .font(.noraBody)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.noraTextSecondary)
                }
            }

            Spacer()
            Spacer()

            VStack(spacing: Spacing.base) {
                Button("Get started", action: onStart)
                    .buttonStyle(.noraPrimary)

                Button("How your data is used") {}
                    .buttonStyle(.noraTertiary)
            }
        }
        .noraScreenPadding()
        .noraScreenBackground()
    }
}

#Preview {
    WelcomeStepView(onStart: {})
}
