import SwiftUI

/// Typography scale for Nora. All fonts derive from Apple's Dynamic Type
/// text styles so layouts reflow correctly under accessibility sizes,
/// rather than fixed point sizes.
extension Font {

    /// 30-34pt, bold. Screen-level titles (e.g. "Today").
    static let noraLargeTitle = Font.system(.largeTitle, design: .default, weight: .bold)

    /// 20-22pt, semibold. Section headers within a screen.
    static let noraSectionTitle = Font.system(.title3, design: .default, weight: .semibold)

    /// 16-17pt, semibold. Titles inside rows, insights, and components.
    static let noraCardTitle = Font.system(.headline, design: .default, weight: .semibold)

    /// 15-17pt, regular. Primary reading text.
    static let noraBody = Font.system(.body, design: .default)

    /// 13-14pt, regular. Supporting/secondary text under a title.
    static let noraSupporting = Font.system(.subheadline, design: .default)

    /// 11-12pt, regular. Timestamps, eyebrow labels, metadata.
    static let noraCaption = Font.system(.caption, design: .default)

    /// 12pt, semibold, uppercased tracking. Category/eyebrow labels.
    static let noraEyebrow = Font.system(.caption, design: .default, weight: .semibold)
}
