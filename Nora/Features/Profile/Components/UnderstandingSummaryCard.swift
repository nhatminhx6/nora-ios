import SwiftUI

/// The "How Nora understands you" card — a condensed, human-readable
/// paragraph rather than a list of raw fields.
struct UnderstandingSummaryCard: View {
    let summary: String
    let onCorrect: () -> Void
    let onAddContext: () -> Void
    let onReset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            HStack {
                Text("How Nora understands you")
                    .font(.noraSectionTitle)
                    .foregroundStyle(Color.noraTextPrimary)
                Spacer()
                Menu {
                    Button("Correct something", systemImage: "pencil", action: onCorrect)
                    Button("Add context", systemImage: "plus.bubble", action: onAddContext)
                    Button("Reset personalization", systemImage: "arrow.counterclockwise", role: .destructive, action: onReset)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(Color.noraTextSecondary)
                        .frame(width: TouchTarget.minimum, height: TouchTarget.minimum)
                }
            }

            Text(summary)
                .font(.noraBody)
                .foregroundStyle(Color.noraTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .noraSurfaceCard()
    }
}

#Preview {
    UnderstandingSummaryCard(
        summary: "Anh là iOS Developer, đang quan tâm SwiftUI, Liverpool FC, Sci-fi movies, đang theo dõi OCB, có kế hoạch Trip to Japan in the fall.",
        onCorrect: {}, onAddContext: {}, onReset: {}
    )
    .noraScreenPadding()
}
