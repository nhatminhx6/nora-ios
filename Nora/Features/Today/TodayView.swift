import SwiftUI

/// The most important screen in the app: within a few seconds the user
/// should know whether anything today deserves their attention.
struct TodayView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @State private var store: TodayStore?
    @State private var displayName: String = "there"

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
        .task {
            if store == nil {
                let newStore = TodayStore(environment: environment)
                store = newStore
                if let profile = try? environment.profileRepository.fetch() {
                    displayName = profile.displayName
                } else if let profile = try? await environment.profileService.fetchProfile() {
                    displayName = profile.displayName
                }
                await newStore.load()
            }
        }
    }

    @ViewBuilder
    private func content(store: TodayStore) -> some View {
        switch store.state {
        case .loading:
            TodaySkeletonView()
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
        VStack(alignment: .leading, spacing: Spacing.xl) {
            TodayHeaderView(displayName: displayName, headline: brief.headline, date: brief.date)

            if brief.importantInsights.isEmpty && brief.otherInsights.isEmpty && brief.upcomingItems.isEmpty {
                EmptyStateView(
                    symbolName: "checkmark.circle",
                    title: "Nothing needs your attention right now.",
                    supportingText: "We're still watching the things you care about."
                )
            } else {
                if !brief.importantInsights.isEmpty {
                    InsightSectionView(
                        title: "Needs attention",
                        insights: brief.importantInsights,
                        onPrimaryAction: { router.showTopicDetail($0.topicId) },
                        onMarkUseful: store.markUseful,
                        onMarkNotRelevant: store.markNotRelevant,
                        onSave: store.save,
                        onMuteTopic: store.muteTopic
                    )
                }

                if !brief.otherInsights.isEmpty {
                    InsightSectionView(
                        title: "Worth knowing",
                        insights: brief.otherInsights,
                        onPrimaryAction: { router.showTopicDetail($0.topicId) },
                        onMarkUseful: store.markUseful,
                        onMarkNotRelevant: store.markNotRelevant,
                        onSave: store.save,
                        onMuteTopic: store.muteTopic
                    )
                }

                if !brief.upcomingItems.isEmpty {
                    UpcomingSectionView(items: brief.upcomingItems)
                }
            }

            DailyReflectionCard(
                prompt: store.reflectionPrompt,
                hasAnswered: store.hasAnsweredReflection,
                onAnswer: store.submitReflection
            )
        }
        .noraScreenPadding()
        .padding(.bottom, Spacing.xxl)
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
