import CoreGraphics

/// Spacing scale. Every layout gap in the app should reference one of these
/// values instead of an arbitrary number, so rhythm stays consistent.
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let base: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

/// Corner radius scale. Only these four sizes should be used anywhere in
/// the app.
enum Radius {
    static let sm: CGFloat = 10
    static let md: CGFloat = 14
    static let lg: CGFloat = 18
    static let xl: CGFloat = 24
}

/// Minimum interactive target size per Apple's accessibility guidance.
enum TouchTarget {
    static let minimum: CGFloat = 44
}
