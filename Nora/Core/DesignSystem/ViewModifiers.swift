import SwiftUI

/// Applies the app's default screen background and safe handling for large
/// titles, avoiding a repeated `.background(Color.noraBackground)` on every
/// screen.
private struct NoraScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background { NoraHeroBackground() }
            .environment(\.colorScheme, .dark)
    }
}

/// Subtle rounded surface used only where content genuinely needs visual
/// separation from a plain list (e.g. the onboarding review card). Not to be
/// used as a default wrapper for every row — plain list rows with dividers
/// are preferred elsewhere.
private struct NoraSurfaceCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Spacing.base)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
            .background(Color.noraGlassTeal.opacity(0.70), in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .strokeBorder(.white.opacity(0.24), lineWidth: 0.8)
            }
    }
}

/// Elevated content card: a clean surface that visibly floats above the
/// screen with a soft shadow. Used for the Today feed so each insight reads
/// as a distinct, tappable card rather than a flat list row.
private struct NoraElevatedCard: ViewModifier {
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)

        content
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.md)
            .background(
                shape
                    .fill(.ultraThinMaterial)
                    .overlay {
                        shape.fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.12, green: 0.34, blue: 0.37).opacity(0.90),
                                    Color(red: 0.18, green: 0.28, blue: 0.30).opacity(0.88),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    }
                    .overlay(alignment: .topTrailing) {
                        RadialGradient(
                            colors: [Color.noraGlow.opacity(0.16), .clear],
                            center: .topTrailing,
                            startRadius: 0,
                            endRadius: 170
                        )
                        .clipShape(shape)
                    }
            )
            .overlay(
                shape
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.62),
                                Color.noraAccentBright.opacity(0.30),
                                Color.white.opacity(0.10),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [.white.opacity(0.20), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 42)
                .clipShape(shape)
                .allowsHitTesting(false)
            }
            .shadow(color: Color.noraAccent.opacity(0.24), radius: 24, y: 12)
            .shadow(color: .black.opacity(0.18), radius: 10, y: 5)
    }
}

/// Standard horizontal screen padding.
private struct NoraScreenPadding: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(.horizontal, Spacing.base)
    }
}

/// Shared background for free-text inputs (onboarding text fields, the
/// topic detail natural-language editor) so every text entry point looks
/// the same.
private struct NoraInputFieldBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Spacing.base)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .strokeBorder(.white.opacity(0.22), lineWidth: 0.8)
            }
    }
}

extension View {
    func noraScreenBackground() -> some View {
        modifier(NoraScreenBackground())
    }

    func noraSurfaceCard() -> some View {
        modifier(NoraSurfaceCard())
    }

    func noraElevatedCard() -> some View {
        modifier(NoraElevatedCard())
    }

    func noraScreenPadding() -> some View {
        modifier(NoraScreenPadding())
    }

    func noraInputFieldBackground() -> some View {
        modifier(NoraInputFieldBackground())
    }
}
