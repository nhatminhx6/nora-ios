import SwiftUI

/// Semantic color tokens for Nora. Views must never reference raw colors or
/// hex values directly — always go through `Color.nora*` so Light/Dark Mode
/// and future palette tweaks stay centralized in this one file.
extension Color {

    // MARK: - Surfaces

    /// Primary app background. Matches the system background so content
    /// feels native rather than "designed on top of" iOS.
    static let noraBackground = Color(uiColor: .systemBackground)

    /// Secondary surface used sparingly for grouped sections (e.g. inset
    /// groups, the composer bar). Slightly offset from the background.
    static let noraSurface = Color(uiColor: .secondarySystemBackground)

    /// Elevated surface for the rare case a control needs to sit above a
    /// secondary surface (e.g. a chip on a grouped row).
    static let noraSurfaceElevated = Color(uiColor: .tertiarySystemBackground)

    /// Hairline divider color for native list separators and rules.
    static let noraDivider = Color(uiColor: .separator)

    // MARK: - Text

    static let noraTextPrimary = Color(uiColor: .label)
    static let noraTextSecondary = Color(uiColor: .secondaryLabel)
    static let noraTextTertiary = Color(uiColor: .tertiaryLabel)

    // MARK: - Brand

    /// The single accent color used across the app for interactive
    /// elements, selection states, and emphasis.
    static let noraAccent = Color(
        light: UIColor(red: 0.20, green: 0.36, blue: 0.85, alpha: 1),
        dark: UIColor(red: 0.42, green: 0.55, blue: 1.0, alpha: 1)
    )

    /// Soft tint of the accent color, used behind selected chips or icons.
    static let noraAccentSoft = Color(
        light: UIColor(red: 0.20, green: 0.36, blue: 0.85, alpha: 0.1),
        dark: UIColor(red: 0.42, green: 0.55, blue: 1.0, alpha: 0.16)
    )

    // MARK: - Semantic status

    static let noraPositive = Color(
        light: UIColor(red: 0.16, green: 0.55, blue: 0.35, alpha: 1),
        dark: UIColor(red: 0.36, green: 0.78, blue: 0.55, alpha: 1)
    )

    static let noraWarning = Color(
        light: UIColor(red: 0.72, green: 0.48, blue: 0.05, alpha: 1),
        dark: UIColor(red: 0.92, green: 0.66, blue: 0.28, alpha: 1)
    )

    static let noraCritical = Color(
        light: UIColor(red: 0.75, green: 0.20, blue: 0.20, alpha: 1),
        dark: UIColor(red: 0.95, green: 0.42, blue: 0.42, alpha: 1)
    )

    // MARK: - Convenience initializer

    /// Builds a dynamic color that resolves differently in Light and Dark
    /// Mode, without needing an asset catalog entry.
    init(light: UIColor, dark: UIColor) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}
