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
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(content: insight.summary)
                .font(.noraBody)
                .foregroundStyle(.white.opacity(0.84))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Text(content: insight.relevanceReason)
                .font(.noraSupporting)
                .foregroundStyle(.white.opacity(0.68))
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
            .foregroundStyle(headerColor)

            Spacer()

            Text(NoraDateFormat.relativeTimestamp(insight.publishedAt, locale: locale))
                .font(.noraCaption)
                .foregroundStyle(.white.opacity(0.58))
        }
    }

    private var footer: some View {
        HStack(spacing: Spacing.md) {
            if let sourceURL = insight.sourceURL {
                Link(destination: sourceURL) {
                    Label(insight.sourceName ?? "Open source", systemImage: "arrow.up.right.square")
                        .font(.noraCaption)
                        .foregroundStyle(Color.noraAccentBright)
                        .labelStyle(.titleAndIcon)
                        .lineLimit(1)
                }
            } else {
                Label("\(insight.sourceCount) sources", systemImage: "doc.text")
                    .font(.noraCaption)
                    .foregroundStyle(.white.opacity(0.58))
                    .labelStyle(.titleAndIcon)
            }

            Spacer()

            if insight.sourceURL == nil, let action = insight.suggestedAction, let onPrimaryAction {
                Button(action: {
                    Haptics.play(.light)
                    onPrimaryAction()
                }) {
                    Text(content: action)
                        .font(.noraSupporting.weight(.semibold))
                        .foregroundStyle(Color.noraAccentBright)
                        .padding(.horizontal, Spacing.sm)
                        .frame(minHeight: 34)
                        .background(Color.noraGlassSelected.opacity(0.44), in: Capsule())
                        .overlay {
                            Capsule()
                                .strokeBorder(Color.noraAccentBright.opacity(0.46), lineWidth: 0.7)
                        }
                }
                .buttonStyle(.plain)
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
                    .foregroundStyle(.white.opacity(0.62))
                    .frame(width: TouchTarget.minimum, height: TouchTarget.minimum)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("More feedback options")
        }
    }

    private var headerColor: Color {
        switch insight.type {
        case .important, .actionRequired:
            Color.noraWarning
        case .resolved:
            Color.noraPositive
        case .informational, .upcoming:
            .white.opacity(0.74)
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
