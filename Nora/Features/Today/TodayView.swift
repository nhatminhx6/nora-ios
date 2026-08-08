import SwiftUI

/// The most important screen in the app: within a few seconds the user
/// should know whether anything today deserves their attention.
struct TodayView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @State private var store: TodayStore?
    @State private var displayName: String = ""
    @State private var selectedCategory = "all"

    var body: some View {
        ScrollView {
            if let store {
                content(store: store)
            }
        }
        .background { NoraHeroBackground() }
        .environment(\.colorScheme, .dark)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .refreshable {
            if let store { await store.refresh() }
        }
        .task {
            if store == nil {
                let newStore = TodayStore(environment: environment)
                store = newStore
                if let profile = try? await environment.profileService.fetchProfile() {
                    displayName = profile.displayName
                }
                await newStore.load()
            }
        }
        .overlay {
            if let store, store.isPerformingAction {
                NoraLoadingOverlay()
            }
        }
    }

    @ViewBuilder
    private func content(store: TodayStore) -> some View {
        switch store.state {
        case .loading:
            NoraFullscreenLoadingView(label: "Preparing your latest brief…")
                .frame(minHeight: UIScreen.main.bounds.height)
        case .error:
            ErrorStateView(
                title: "Today's brief could not be refreshed.",
                supportingText: "Check your connection and try again.",
                onRetry: { Task { await store.refresh() } }
            )
            .padding(.top, Spacing.xxl)
        case .loaded(let brief):
            loadedContent(store: store, brief: brief)
        }
    }

    private func loadedContent(store: TodayStore, brief: Brief) -> some View {
        let filters = availableFilters(for: brief)
        let selectedCategory = effectiveCategory(in: filters)
        let importantInsights = filtered(brief.importantInsights, by: selectedCategory)
        let otherInsights = filtered(brief.otherInsights, by: selectedCategory)
        let upcomingItems = filtered(brief.upcomingItems, by: selectedCategory)

        return VStack(alignment: .leading, spacing: Spacing.xl) {
            TodayHeaderView(displayName: displayName, headline: brief.headline, date: brief.date)

            if filters.count > 1 {
                categoryFilterBar(filters: filters, selectedCategory: selectedCategory)
            }

            if brief.importantInsights.isEmpty && brief.otherInsights.isEmpty && brief.upcomingItems.isEmpty {
                HStack(spacing: Spacing.md) {
                    NoraLoadingMark(size: 28)
                    Text("Nora is preparing your latest brief…")
                        .font(.noraSupporting)
                        .foregroundStyle(Color.noraTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .noraSurfaceCard()
            } else {
                if !importantInsights.isEmpty {
                    InsightSectionView(
                        title: "Needs attention",
                        insights: importantInsights,
                        onPrimaryAction: { router.showTopicDetail($0.topicId) },
                        onMarkUseful: store.markUseful,
                        onMarkNotRelevant: store.markNotRelevant,
                        onSave: store.save,
                        onMuteTopic: store.muteTopic
                    )
                }

                if !otherInsights.isEmpty {
                    InsightSectionView(
                        title: "Worth knowing",
                        insights: otherInsights,
                        onPrimaryAction: { router.showTopicDetail($0.topicId) },
                        onMarkUseful: store.markUseful,
                        onMarkNotRelevant: store.markNotRelevant,
                        onSave: store.save,
                        onMuteTopic: store.muteTopic
                    )
                }

                if !upcomingItems.isEmpty {
                    UpcomingSectionView(items: upcomingItems)
                }

                if store.hasNextPage || store.isLoadingMore {
                    ProgressView()
                        .tint(Color.noraAccentBright)
                        .frame(maxWidth: .infinity, minHeight: TouchTarget.minimum)
                        .onAppear { Task { await store.loadMore() } }
                }
            }

        }
        .noraScreenPadding()
        .padding(.bottom, Spacing.xxl)
    }

    private func availableFilters(for brief: Brief) -> [BriefFilter] {
        if !brief.filters.isEmpty { return brief.filters }

        let categories = (brief.importantInsights.map(\.category) +
            brief.otherInsights.map(\.category) +
            brief.upcomingItems.map(\.category)).reduce(into: [TopicCategory]()) { result, category in
                if !result.contains(category) { result.append(category) }
            }
        let total = brief.importantInsights.count + brief.otherInsights.count + brief.upcomingItems.count
        return [BriefFilter(key: "all", title: "All", count: total)] + categories.map { category in
            BriefFilter(
                key: category.rawValue,
                title: String(localized: category.title),
                count: brief.importantInsights.count(where: { $0.category == category }) +
                    brief.otherInsights.count(where: { $0.category == category }) +
                    brief.upcomingItems.count(where: { $0.category == category })
            )
        }
    }

    private func effectiveCategory(in filters: [BriefFilter]) -> String {
        filters.contains(where: { $0.key == selectedCategory }) ? selectedCategory : "all"
    }

    private func filtered(_ insights: [Insight], by category: String) -> [Insight] {
        category == "all" ? insights : insights.filter { $0.category.rawValue == category }
    }

    private func filtered(_ items: [UpcomingItem], by category: String) -> [UpcomingItem] {
        category == "all" ? items : items.filter { $0.category.rawValue == category }
    }

    private func categoryFilterBar(
        filters: [BriefFilter],
        selectedCategory: String
    ) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.sm) {
                ForEach(filters) { filter in
                    let isSelected = filter.key == selectedCategory
                    Button {
                        self.selectedCategory = filter.key
                        Haptics.play(.light)
                        Task { await store?.selectCategory(filter.key) }
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Text(filter.title)
                            Text("\(filter.count)")
                                .foregroundStyle(isSelected ? Color.white.opacity(0.72) : Color.noraTextTertiary)
                        }
                        .font(.noraSupporting)
                        .foregroundStyle(isSelected ? Color.white : Color.noraTextSecondary)
                        .padding(.horizontal, Spacing.base)
                        .frame(minHeight: TouchTarget.minimum)
                        .background(
                            isSelected ? Color.noraAccent : Color.noraSurface,
                            in: Capsule()
                        )
                        .overlay {
                            Capsule()
                                .strokeBorder(
                                    isSelected ? Color.noraAccentBright.opacity(0.7) : Color.white.opacity(0.16),
                                    lineWidth: 1
                                )
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(filter.title), \(filter.count) items")
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview("Loaded — Light") {
    NavigationStack { TodayView() }
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
}

#Preview("Loaded — Dark") {
    NavigationStack { TodayView() }
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
        .preferredColorScheme(.dark)
}

#Preview("Large Dynamic Type") {
    NavigationStack { TodayView() }
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
        .environment(\.dynamicTypeSize, .accessibility3)
}
