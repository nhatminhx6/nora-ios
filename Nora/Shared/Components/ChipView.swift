import SwiftUI

/// Selectable pill used for quick replies and onboarding suggestions.
struct ChipView: View {
    let title: String
    var isSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptics.play(.selection)
            action()
        }) {
            Text(content: title)
                .font(.noraSupporting.weight(.medium))
                .foregroundStyle(isSelected ? .white : Color.noraTextPrimary)
                .padding(.horizontal, Spacing.base)
                .frame(minHeight: 36)
                .background(isSelected ? Color.noraAccent : Color.noraSurface)
                .clipShape(Capsule())
        }
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    HStack {
        ChipView(title: "Bản 2.0L Premium", isSelected: true, action: {})
        ChipView(title: "Bản 2.5L AWD", action: {})
    }
    .padding()
}
