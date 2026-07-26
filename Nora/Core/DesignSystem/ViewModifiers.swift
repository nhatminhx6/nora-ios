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

    func noraScreenPadding() -> some View {
        modifier(NoraScreenPadding())
    }

    func noraInputFieldBackground() -> some View {
        modifier(NoraInputFieldBackground())
    }
}
