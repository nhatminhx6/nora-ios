import SwiftUI

/// The very first screen. No robot illustration, no account wall — an
/// atmospheric, editorial hero that states the promise and offers one way
/// in. Large type, left-aligned, calm depth from the hero backdrop.
struct WelcomeStepView: View {
    let onStart: () -> Void

    /// Scales the hero headline with Dynamic Type instead of a fixed size.
    @ScaledMetric(relativeTo: .largeTitle) private var heroSize: CGFloat = 52

    var body: some View {
        ZStack {
            NoraHeroBackground()

            VStack(alignment: .leading, spacing: 0) {
                brandmark
                    .padding(.top, Spacing.sm)

                Spacer()

                VStack(alignment: .leading, spacing: Spacing.base) {
                    Text("Welcome")
                        .font(.system(size: heroSize, weight: .bold, design: .default))
                        .foregroundStyle(Color.noraTextPrimary)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)

                    Text("A personal brief built around your life.")
                        .font(.noraSectionTitle)
                        .foregroundStyle(Color.noraTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Nora learns what matters to you, follows it, and only speaks up when something is worth your attention.")
                        .font(.noraBody)
                        .foregroundStyle(Color.noraTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
                Spacer()

                VStack(spacing: Spacing.xs) {
                    Button("Get started", action: onStart)
                        .buttonStyle(.noraPrimary)

                    Button("How your data is used") {}
                        .buttonStyle(.noraTertiary)
                }
                .padding(.bottom, Spacing.sm)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .noraScreenPadding()
        }
        .environment(\.colorScheme, .dark)
    }

    private var brandmark: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "circle.hexagongrid.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.noraAccent)

            Text("Nora")
                .font(.system(.title3, design: .default, weight: .semibold))
                .foregroundStyle(Color.noraTextPrimary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Nora")
    }
}

#Preview("Light") {
    WelcomeStepView(onStart: {})
}

#Preview("Dark") {
    WelcomeStepView(onStart: {})
        .preferredColorScheme(.dark)
}
