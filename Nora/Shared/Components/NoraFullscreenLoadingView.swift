import SwiftUI

/// Nora's shared full-screen loading state for initial API-backed screens.
struct NoraFullscreenLoadingView: View {
    var label: LocalizedStringKey = "Nora is getting things ready…"

    var body: some View {
        ZStack {
            NoraHeroBackground(intensity: 1.15)

            VStack(spacing: Spacing.xl) {
                NoraLoadingMark()

                VStack(spacing: Spacing.sm) {
                    Text(label)
                        .font(.noraCardTitle)
                        .foregroundStyle(Color.noraTextPrimary)
                        .multilineTextAlignment(.center)

                    Text("Finding what matters most for you")
                        .font(.noraSupporting)
                        .foregroundStyle(Color.noraTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.xxl)
            .frame(maxWidth: 340)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            }
            .shadow(color: Color.noraAccent.opacity(0.22), radius: 32, y: 12)
            .padding(.horizontal, Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(\.colorScheme, .dark)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
    }
}

/// Branded indeterminate loading mark without UIKit's default spinner.
struct NoraLoadingMark: View {
    var size: CGFloat = 92

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.noraAccent.opacity(0.14))
                .frame(width: size * 1.18, height: size * 1.18)
                .blur(radius: size * 0.12)
                .scaleEffect(isAnimating && !reduceMotion ? 1.08 : 0.92)

            Circle()
                .trim(from: 0.06, to: 0.78)
                .stroke(
                    AngularGradient(
                        colors: [.noraAccentBright, .noraGlow, .noraCritical, .noraAccentBright],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: size * 0.085, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(isAnimating && !reduceMotion ? 360 : 24))

            Circle()
                .trim(from: 0.12, to: 0.54)
                .stroke(
                    LinearGradient(
                        colors: [.noraGlow, .noraAccentBright],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: size * 0.035, lineCap: .round)
                )
                .frame(width: size * 0.72, height: size * 0.72)
                .rotationEffect(.degrees(isAnimating && !reduceMotion ? -360 : -18))

            Image(systemName: "sparkles")
                .font(.system(size: size * 0.28, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.noraGlow, .noraAccentBright],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(isAnimating && !reduceMotion ? 1.08 : 0.92)
        }
        .frame(width: size * 1.25, height: size * 1.25)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 1.65).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    NoraFullscreenLoadingView(label: "Preparing your latest brief…")
}
