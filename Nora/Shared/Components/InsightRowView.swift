import SwiftUI

/// The single reusable representation of an `Insight` across Today, Topic
/// Detail, and search. Designed as a divider-separated row rather than a
/// boxed card, so a list of insights reads as one continuous, calm list.
struct InsightRowView: View {
    let insight: Insight
    var onPrimaryAction: (() -> Void)?
    var onMarkUseful: (() -> Void)?
    var onMarkNotRelevant: (() -> Void)?
    var onSave: (() -> Void)?
    var onMuteTopic: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            header

            Text(content: insight.title)
                .font(.noraCardTitle)
                .foregroundStyle(Color.noraTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(content: insight.summary)
                .font(.noraBody)
                .foregroundStyle(Color.noraTextSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Text(content: insight.relevanceReason)
                .font(.noraSupporting)
                .foregroundStyle(Color.noraTextTertiary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            footer
        }
        .padding(.vertical, Spacing.sm)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Label {
                Text(insight.type == .important || insight.type == .actionRequired ? insight.type.label : insight.category.title)
                    .font(.noraEyebrow)
            } icon: {
                Image(systemName: insight.type.symbolName)
                    .font(.noraEyebrow)
            }
            .labelStyle(.titleAndIcon)
            .foregroundStyle(insight.type.tintColor)

            Spacer()

            Text(NoraDateFormat.relativeTimestamp(insight.publishedAt, locale: locale))
                .font(.noraCaption)
                .foregroundStyle(Color.noraTextTertiary)
        }
    }

    private var footer: some View {
        HStack(spacing: Spacing.md) {
            Label("\(insight.sourceCount) sources", systemImage: "doc.text")
                .font(.noraCaption)
                .foregroundStyle(Color.noraTextTertiary)
                .labelStyle(.titleAndIcon)

            Spacer()

            if let action = insight.suggestedAction, let onPrimaryAction {
                Button(action: {
                    Haptics.play(.light)
                    onPrimaryAction()
                }) {
                    Text(content: action)
                }
                .buttonStyle(.noraTertiary)
            }

            feedbackMenu
        }
    }

    @ViewBuilder
    private var feedbackMenu: some View {
        if onMarkUseful != nil || onMarkNotRelevant != nil || onSave != nil || onMuteTopic != nil {
            Menu {
                if let onMarkUseful {
                    Button("Useful", systemImage: "hand.thumbsup", action: onMarkUseful)
                }
                if let onMarkNotRelevant {
                    Button("Not relevant", systemImage: "hand.thumbsdown", action: onMarkNotRelevant)
                }
                if let onSave {
                    Button(insight.isSaved ? "Saved" : "Save", systemImage: insight.isSaved ? "bookmark.fill" : "bookmark", action: onSave)
                }
                if let onMuteTopic {
                    Button("Mute \(insight.topicName)", systemImage: "bell.slash", role: .destructive, action: onMuteTopic)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(Color.noraTextTertiary)
                    .frame(width: TouchTarget.minimum, height: TouchTarget.minimum)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("More feedback options")
        }
    }
}

#Preview("Insight row states") {
    List {
        ForEach(PreviewData.allInsights) { insight in
            InsightRowView(
                insight: insight,
                onPrimaryAction: {},
                onMarkUseful: {},
                onMarkNotRelevant: {},
                onSave: {},
                onMuteTopic: {}
            )
            .noraListRow()
        }
    }
    .listStyle(.plain)
}
