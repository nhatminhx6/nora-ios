import SwiftUI

/// Nora's cinematic first impression. The city photograph provides the
/// atmosphere; every label and control remains native SwiftUI for crisp type,
/// accessibility, localization, and reliable interaction.
struct WelcomeStepView: View {
    let onStart: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var welcomeSize: CGFloat = 54
    @State private var hasAppeared = false

    var body: some View {
        ZStack(alignment: .bottom) {
            background

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    topBar
                    hero
                    quickContext
                    highlights
                    privacyAction
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.sm)
                .padding(.bottom, 116)
            }
            .scrollIndicators(.hidden)

            bottomDock
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.sm)
        }
        .environment(\.colorScheme, .dark)
        .task {
            guard !hasAppeared else { return }
            if reduceMotion {
                hasAppeared = true
            } else {
                withAnimation(.easeOut(duration: 0.7)) {
                    hasAppeared = true
                }
            }
        }
    }

    private var background: some View {
        GeometryReader { proxy in
            Image("WelcomeCity")
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
                .overlay {
                    LinearGradient(
                        stops: [
                            .init(color: Color(red: 0.68, green: 0.78, blue: 0.80).opacity(0.28), location: 0),
                            .init(color: .clear, location: 0.36),
                            .init(color: Color(red: 0.02, green: 0.07, blue: 0.09).opacity(0.30), location: 0.55),
                            .init(color: Color(red: 0.01, green: 0.04, blue: 0.06).opacity(0.90), location: 1),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private var topBar: some View {
        HStack {
            Image(systemName: "circle.hexagongrid.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white.opacity(0.90))

            Spacer()

            Text("Nora")
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(.white.opacity(0.92))

            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white.opacity(0.90))
        }
        .frame(minHeight: 44)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Nora")
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Nora")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .tracking(-1.6)
                .foregroundStyle(Color(red: 0.02, green: 0.12, blue: 0.15))

            Text("Welcome")
                .font(.system(size: welcomeSize, weight: .bold))
                .tracking(-1.8)
                .foregroundStyle(.white)
                .minimumScaleFactor(0.72)
                .lineLimit(1)

            Text("A personal brief built around your life.")
                .font(.noraSectionTitle)
                .foregroundStyle(.white.opacity(0.96))

            Text("Nora learns what matters to you, follows it, and only speaks up when something is worth your attention.")
                .font(.noraBody)
                .foregroundStyle(.white.opacity(0.78))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            Button("Get started", action: onStart)
                .buttonStyle(WelcomePrimaryButtonStyle())
                .padding(.top, Spacing.sm)
        }
        .padding(.top, Spacing.xl)
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 16)
    }

    private var quickContext: some View {
        HStack(spacing: Spacing.sm) {
            WelcomeOrb(symbol: "sparkles", accessibilityLabel: "Personalized")
            WelcomeOrb(symbol: "bell.badge.fill", accessibilityLabel: "Important alerts")

            VStack(alignment: .leading, spacing: 2) {
                Text("Calm by default")
                    .font(.noraSupporting.weight(.semibold))
                    .foregroundStyle(.white)
                Text("Only what deserves your attention")
                    .font(.noraCaption)
                    .foregroundStyle(.white.opacity(0.66))
            }
            .padding(.leading, Spacing.xs)
        }
        .padding(.top, 44)
    }

    private var highlights: some View {
        VStack(spacing: Spacing.sm) {
            WelcomeHighlight(
                symbol: "scope",
                title: "Built around you",
                supportingText: "Work, investments, interests and plans — understood as one connected life."
            )

            WelcomeHighlight(
                symbol: "line.3.horizontal.decrease.circle.fill",
                title: "Noise, filtered",
                supportingText: "Nora watches in the background and surfaces only what changes something for you."
            )

            WelcomeHighlight(
                symbol: "lock.fill",
                title: "Private by design",
                supportingText: "Your context stays under your control. Correct it, remove it, or reset at any time."
            )
        }
        .padding(.top, Spacing.lg)
    }

    private var privacyAction: some View {
        Button("How your data is used") {}
            .font(.noraSupporting.weight(.semibold))
            .foregroundStyle(.white.opacity(0.82))
            .frame(minHeight: 44)
            .padding(.top, Spacing.sm)
    }

    private var bottomDock: some View {
        HStack(spacing: Spacing.sm) {
            WelcomeDockItem(symbol: "sun.max.fill", title: "Today", isSelected: false)
            WelcomeDockItem(symbol: "bubble.left.and.text.bubble.right.fill", title: "Assistant", isSelected: false)
            WelcomeDockItem(symbol: "eye.fill", title: "Following", isSelected: true)
            WelcomeDockItem(symbol: "person.crop.circle.fill", title: "Profile", isSelected: false)
        }
        .padding(Spacing.sm)
        .background(Color.noraGlassTeal.opacity(0.88), in: RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                .strokeBorder(.white.opacity(0.26), lineWidth: 0.8)
        }
        .shadow(color: .black.opacity(0.28), radius: 24, y: 12)
    }
}

private struct WelcomePrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.noraBody.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: 210)
            .frame(minHeight: 56)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.10, green: 0.68, blue: 0.72),
                        Color(red: 0.04, green: 0.49, blue: 0.57),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .strokeBorder(.white.opacity(0.32), lineWidth: 0.8)
            }
            .shadow(color: Color(red: 0.02, green: 0.55, blue: 0.62).opacity(0.50), radius: 20, y: 10)
            .shadow(color: .black.opacity(0.24), radius: 8, y: 5)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

private struct WelcomeOrb: View {
    let symbol: String
    let accessibilityLabel: LocalizedStringKey

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 54, height: 54)
            .background(Color.noraChipIdle.opacity(0.84), in: Circle())
            .overlay {
                Circle().strokeBorder(.white.opacity(0.30), lineWidth: 0.8)
            }
            .shadow(color: .black.opacity(0.20), radius: 10, y: 5)
            .accessibilityLabel(accessibilityLabel)
    }
}

private struct WelcomeHighlight: View {
    let symbol: String
    let title: LocalizedStringKey
    let supportingText: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(red: 0.55, green: 0.94, blue: 0.95))
                .frame(width: 42, height: 42)
                .background(Color.noraSurfaceElevated.opacity(0.92), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.noraCardTitle)
                    .foregroundStyle(.white)
                Text(supportingText)
                    .font(.noraSupporting)
                    .foregroundStyle(.white.opacity(0.70))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(Spacing.md)
        .background(Color.noraGlassWarm.opacity(0.88), in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.38), .white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        }
        .shadow(color: .black.opacity(0.22), radius: 16, y: 8)
    }
}

private struct WelcomeDockItem: View {
    let symbol: String
    let title: LocalizedStringKey
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .foregroundStyle(isSelected ? Color(red: 0.03, green: 0.25, blue: 0.29) : .white.opacity(0.82))
        .frame(maxWidth: .infinity, minHeight: 58)
        .background(
            isSelected ? Color.noraChipSelected : Color.noraChipIdle.opacity(0.78),
            in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    WelcomeStepView(onStart: {})
}
