import SwiftUI

/// A short row of contextual actions shown only when the conversation is
/// empty — not a permanent chatbot toolbar.
struct QuickActionsBar: View {
    let actions: [String]
    let onTap: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(actions, id: \.self) { action in
                    ChipView(title: action, action: { onTap(action) })
                }
            }
            .noraScreenPadding()
        }
    }
}

#Preview {
    QuickActionsBar(actions: ["Theo dõi chủ đề mới", "Tóm tắt tuần này"], onTap: { _ in })
}
