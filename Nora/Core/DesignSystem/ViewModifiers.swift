import SwiftUI

/// Applies the app's default screen background and safe handling for large
/// titles, avoiding a repeated `.background(Color.noraBackground)` on every
/// screen.
private struct NoraScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.noraBackground)
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
            .background(Color.noraSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
    }
}

/// Elevated content card: a clean surface that visibly floats above the
/// screen with a soft shadow. Used for the Today feed so each insight reads
/// as a distinct, tappable card rather than a flat list row.
private struct NoraElevatedCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.md)
            // Frosted glass: the atmospheric hero shows through, tinted.
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
            // Top-down sheen for a glossy, lifted glass surface.
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.22), Color.white.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.5), Color.white.opacity(0.08)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.75
                    )
            )
            .shadow(color: Color.noraAccent.opacity(0.10), radius: 18, y: 8)
            .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
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
            .background(Color.noraSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
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
