import UIKit

/// Style of haptic feedback for a given interaction.
enum HapticStyle {
    case light
    case medium
    case success
    case selection
}

/// Thin wrapper around `UIFeedbackGenerator` so views never talk to UIKit
/// directly. Kept as a lightweight enum-namespaced API rather than a
/// singleton class.
enum Haptics {
    @MainActor
    static func play(_ style: HapticStyle) {
        switch style {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
}
