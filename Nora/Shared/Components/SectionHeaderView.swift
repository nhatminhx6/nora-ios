import SwiftUI

/// Consistent section header used throughout Today, Following, and Profile.
struct SectionHeaderView: View {
    let title: String
    var trailingActionTitle: String?
    var onTrailingAction: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(content: title)
                .font(.noraSectionTitle)
                .foregroundStyle(Color.noraTextPrimary)

            Spacer()

            if let trailingActionTitle, let onTrailingAction {
                Button(action: onTrailingAction) { Text(content: trailingActionTitle) }
                    .buttonStyle(.noraTertiary)
                    .font(.noraSupporting.weight(.medium))
            }
        }
    }
}

#Preview {
    SectionHeaderView(title: "Needs attention", trailingActionTitle: "See all", onTrailingAction: {})
        .noraScreenPadding()
}
