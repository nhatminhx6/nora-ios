import SwiftUI

/// Consistent list-row presentation used across Following, Topic Detail, and
/// Profile so we get a native list feel instead of ad-hoc card stacking.
struct NoraListRowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, Spacing.sm)
            .listRowInsets(EdgeInsets(top: 0, leading: Spacing.base, bottom: 0, trailing: Spacing.base))
            .listRowBackground(Color.noraBackground)
    }
}

extension View {
    func noraListRow() -> some View {
        modifier(NoraListRowStyle())
    }
}
