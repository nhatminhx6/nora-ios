import SwiftUI

/// Filled accent button. Used for the single primary action on a screen.
struct PrimaryButtonStyle: ButtonStyle {
    var isFullWidth: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.noraCardTitle)
            .foregroundStyle(.white)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(minHeight: TouchTarget.minimum)
            .padding(.horizontal, Spacing.lg)
            .background(Color.noraAccent.opacity(configuration.isPressed ? 0.85 : 1))
            .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Tinted, low-emphasis button for secondary actions.
struct SecondaryButtonStyle: ButtonStyle {
    var isFullWidth: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.noraCardTitle)
            .foregroundStyle(Color.noraAccent)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(minHeight: TouchTarget.minimum)
            .padding(.horizontal, Spacing.lg)
            .background(Color.noraAccentSoft.opacity(configuration.isPressed ? 0.6 : 1))
            .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
    }
}

/// Plain text button for tertiary, low-visual-weight actions.
struct TertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.noraBody.weight(.medium))
            .foregroundStyle(Color.noraAccent)
            .opacity(configuration.isPressed ? 0.6 : 1)
            .frame(minHeight: TouchTarget.minimum)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var noraPrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var noraSecondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

extension ButtonStyle where Self == TertiaryButtonStyle {
    static var noraTertiary: TertiaryButtonStyle { TertiaryButtonStyle() }
}
