import SwiftUI

/// Purposeful empty state — a symbol, a reassuring headline, and optional
/// supporting text or suggestions. Never a generic "No data found."
struct EmptyStateView: View {
    let symbolName: String
    let title: String
    var supportingText: String?
    var suggestions: [String] = []
    var onSuggestionTapped: ((String) -> Void)?

    var body: some View {
        VStack(spacing: Spacing.base) {
            Image(systemName: symbolName)
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(Color.noraTextTertiary)

            VStack(spacing: Spacing.xs) {
                Text(content: title)
                    .font(.noraCardTitle)
                    .foregroundStyle(Color.noraTextPrimary)
                    .multilineTextAlignment(.center)

                if let supportingText {
                    Text(content: supportingText)
                        .font(.noraSupporting)
                        .foregroundStyle(Color.noraTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            if !suggestions.isEmpty {
                VStack(spacing: Spacing.sm) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button {
                            Haptics.play(.selection)
                            onSuggestionTapped?(suggestion)
                        } label: {
                            Text(content: suggestion)
                        }
                        .buttonStyle(.noraSecondary)
                    }
                }
                .padding(.top, Spacing.sm)
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity)
    }
}

#Preview("Today empty") {
    EmptyStateView(
        symbolName: "checkmark.circle",
        title: "Nothing needs your attention right now.",
        supportingText: "We're still watching the things you care about."
    )
}

#Preview("Following empty") {
    EmptyStateView(
        symbolName: "sparkle.magnifyingglass",
        title: "Start with something already on your mind.",
        suggestions: ["A company you follow", "A team you support", "A trip you are planning", "A skill you are learning"]
    )
}
