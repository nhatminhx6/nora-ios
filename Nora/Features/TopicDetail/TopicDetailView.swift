import SwiftUI

struct TopicDetailView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.locale) private var locale
    @State private var store: TopicDetailStore?
    @State private var browserDestination: BrowserDestination?
    let topicId: UUID

    init(topicId: UUID) {
        self.topicId = topicId
    }

    var body: some View {
        Group {
            if let store, let topic = store.topic {
                loaded(store: store, topic: topic)
            } else {
                TodaySkeletonView()
            }
        }
        .background { NoraHeroBackground() }
        .environment(\.colorScheme, .dark)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $browserDestination) { destination in
            InAppBrowserView(url: destination.url)
                .ignoresSafeArea()
        }
        .task {
            if store == nil {
                let newStore = TopicDetailStore(topicId: topicId, environment: environment)
                store = newStore
                await newStore.load()
            }
        }
    }

    private func loaded(store: TopicDetailStore, topic: Topic) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Spacing.xl) {
                header(topic: topic)
                controls(store: store, topic: topic)

                if !topic.trackingRules.isEmpty {
                    trackingRules(topic: topic)
                }

                if let reason = topic.relevanceReason, !reason.isEmpty {
                    whyThisMatters(reason: reason)
                }

                if !upcoming(store.insights).isEmpty {
                    upcomingSection(items: upcoming(store.insights))
                }

                recentInsights(store: store)

                naturalLanguageEdit(store: store)
            }
            .noraScreenPadding()
            .padding(.bottom, 120)
        }
        .navigationTitle(Text(content: topic.name))
    }

    private func header(topic: Topic) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Label {
                Text(topic.category.title)
            } icon: {
                Image(systemName: topic.category.symbolName)
            }
            .font(.noraEyebrow)
            .foregroundStyle(Color.noraTextSecondary)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(content: topic.name)
                    .font(.noraLargeTitle)
                    .foregroundStyle(Color.noraTextPrimary)

                Text(topic.relationship.label)
                    .font(.noraSupporting)
                    .foregroundStyle(Color.noraTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func controls(store: TopicDetailStore, topic: Topic) -> some View {
        VStack(spacing: 0) {
            Menu {
                ForEach(TopicPriority.allCases) { priority in
                    Button { store.updatePriority(priority) } label: { Text(priority.label) }
                }
            } label: {
                controlRow(title: "Priority", value: topic.priority.label)
            }
            Divider().overlay(Color.noraDivider)
            Menu {
                ForEach(TopicNotificationMode.allCases) { mode in
                    Button { store.updateNotificationMode(mode) } label: { Text(mode.label) }
                }
            } label: {
                controlRow(title: "Notifications", value: topic.notificationMode.label)
            }
        }
        .noraSurfaceCard()
    }

    private func controlRow(title: LocalizedStringKey, value: LocalizedStringResource) -> some View {
        HStack {
            Text(title)
                .font(.noraBody)
                .foregroundStyle(Color.noraTextPrimary)
            Spacer()
            Text(value)
                .font(.noraBody)
                .foregroundStyle(Color.noraTextSecondary)
            Image(systemName: "chevron.up.chevron.down")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.noraTextTertiary)
        }
        .padding(.vertical, Spacing.sm)
        .contentShape(Rectangle())
    }

    private func trackingRules(topic: Topic) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeaderView(title: "What Nora is tracking")
            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(topic.trackingRules, id: \.self) { rule in
                    HStack(alignment: .top, spacing: Spacing.sm) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.noraAccent)
                            .padding(.top, 2)
                        Text(content: rule)
                            .font(.noraBody)
                            .foregroundStyle(Color.noraTextPrimary)
                    }
                }
            }
        }
    }

    private func whyThisMatters(reason: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeaderView(title: "Why this matters to you")
            Text(content: reason)
                .font(.noraBody)
                .foregroundStyle(Color.noraTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .noraSurfaceCard()
        }
    }

    private func upcoming(_ insights: [Insight]) -> [Insight] {
        insights.filter { $0.eventDate != nil }
    }

    private func upcomingSection(items: [Insight]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeaderView(title: "Upcoming")
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, insight in
                    HStack {
                        Text(content: insight.title)
                            .font(.noraBody)
                            .foregroundStyle(Color.noraTextPrimary)
                        Spacer()
                        if let date = insight.eventDate {
                            Text(NoraDateFormat.countdown(to: date, locale: locale))
                                .font(.noraSupporting.weight(.medium))
                                .foregroundStyle(Color.noraTextSecondary)
                        }
                    }
                    .padding(.vertical, Spacing.sm)
                    if index < items.count - 1 {
                        Divider().overlay(Color.noraDivider)
                    }
                }
            }
        }
    }

    private func recentInsights(store: TopicDetailStore) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                SectionHeaderView(title: "Recent insight")
                Spacer()
                if !store.insights.isEmpty {
                    Text("\(store.insights.count)")
                        .font(.noraCaption.weight(.semibold))
                        .foregroundStyle(Color.noraTextSecondary)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.white.opacity(0.10), in: Capsule())
                }
            }

            if store.insights.isEmpty {
                ContentUnavailableView {
                    Label("No recent updates", systemImage: "checkmark.circle")
                } description: {
                    Text("Nora is still watching this topic for you.")
                }
                .foregroundStyle(Color.noraTextSecondary)
                .frame(maxWidth: .infinity)
                .noraSurfaceCard()
            } else {
                LazyVStack(spacing: Spacing.md) {
                    ForEach(store.insights) { insight in
                        insightCard(insight)
                    }
                }
            }
        }
    }

    private func insightCard(_ insight: Insight) -> some View {
        Button {
            if let sourceURL = insight.sourceURL {
                browserDestination = BrowserDestination(url: sourceURL)
            }
        } label: {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: insight.type.symbolName)
                        .foregroundStyle(Color.noraAccent)
                    Text(insight.type.label)
                        .font(.noraCaption.weight(.semibold))
                        .foregroundStyle(Color.noraTextSecondary)
                    Spacer()
                    Text(NoraDateFormat.relativeTimestamp(insight.publishedAt, locale: locale))
                        .font(.noraCaption)
                        .foregroundStyle(Color.noraTextTertiary)
                }

                Text(content: insight.title)
                    .font(.noraCardTitle)
                    .foregroundStyle(Color.noraTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(content: insight.summary)
                    .font(.noraSupporting)
                    .foregroundStyle(Color.noraTextSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                if insight.sourceURL != nil {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "safari")
                        Text(insight.sourceName ?? "Open source")
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.noraCaption.weight(.semibold))
                    .foregroundStyle(Color.noraAccent)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .noraSurfaceCard()
        }
        .buttonStyle(.plain)
        .disabled(insight.sourceURL == nil)
    }

    private func naturalLanguageEdit(store: TopicDetailStore) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeaderView(title: "Adjust in your own words")
            Text("Example: \"Only alert me when something is truly serious.\"")
                .font(.noraCaption)
                .foregroundStyle(Color.noraTextTertiary)

            HStack(spacing: Spacing.sm) {
                TextField("Tell Nora what you want", text: Bindable(store).naturalLanguageInput, axis: .vertical)
                    .font(.noraBody)
                    .noraInputFieldBackground()

                Button {
                    store.applyNaturalLanguageEdit()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.noraAccent)
                        .clipShape(Circle())
                }
                .disabled(store.naturalLanguageInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TopicDetailView(topicId: PreviewData.topicOCB.id)
    }
    .environment(AppEnvironment.preview())
}
