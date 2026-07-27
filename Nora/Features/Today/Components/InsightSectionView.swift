import SwiftUI

/// Renders a titled group of insights as a feed of elevated cards — used for
/// both "Needs attention" and "Worth knowing" so the two sections share one
/// implementation.
struct InsightSectionView: View {
    let title: String
    let insights: [Insight]
    let onPrimaryAction: (Insight) -> Void
    let onMarkUseful: (Insight) -> Void
    let onMarkNotRelevant: (Insight) -> Void
    let onSave: (Insight) -> Void
    let onMuteTopic: (Insight) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeaderView(title: title)

            ForEach(insights) { insight in
                InsightRowView(
                    insight: insight,
                    onPrimaryAction: insight.suggestedAction != nil ? { onPrimaryAction(insight) } : nil,
                    onMarkUseful: { onMarkUseful(insight) },
                    onMarkNotRelevant: { onMarkNotRelevant(insight) },
                    onSave: { onSave(insight) },
                    onMuteTopic: { onMuteTopic(insight) }
                )
                .noraElevatedCard()
            }
        }
    }
}

#Preview {
    InsightSectionView(
        title: "Needs attention",
        insights: [PreviewData.insightOCBEarnings, PreviewData.insightLiverpoolMatch],
        onPrimaryAction: { _ in },
        onMarkUseful: { _ in },
        onMarkNotRelevant: { _ in },
        onSave: { _ in },
        onMuteTopic: { _ in }
    )
    .noraScreenPadding()
}
