import SwiftUI

/// Renders a titled group of insights as a native divider-separated list —
/// used for both "Needs attention" and "Worth knowing" so the two sections
/// share one implementation.
struct InsightSectionView: View {
    let title: String
    let insights: [Insight]
    let onPrimaryAction: (Insight) -> Void
    let onMarkUseful: (Insight) -> Void
    let onMarkNotRelevant: (Insight) -> Void
    let onSave: (Insight) -> Void
    let onMuteTopic: (Insight) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeaderView(title: title)

            VStack(spacing: 0) {
                ForEach(Array(insights.enumerated()), id: \.element.id) { index, insight in
                    InsightRowView(
                        insight: insight,
                        onPrimaryAction: insight.suggestedAction != nil ? { onPrimaryAction(insight) } : nil,
                        onMarkUseful: { onMarkUseful(insight) },
                        onMarkNotRelevant: { onMarkNotRelevant(insight) },
                        onSave: { onSave(insight) },
                        onMuteTopic: { onMuteTopic(insight) }
                    )
                    if index < insights.count - 1 {
                        Divider().overlay(Color.noraDivider)
                    }
                }
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
