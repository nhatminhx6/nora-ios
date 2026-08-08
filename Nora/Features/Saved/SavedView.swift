import SwiftUI

/// A lightweight home for insights the user explicitly wants to revisit.
struct SavedView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @State private var insights: [Insight] = []
    @State private var loadFailed = false

    var body: some View {
        ZStack {
            NoraHeroBackground()

            Group {
                if loadFailed {
                    ErrorStateView(
                        title: "Saved insights could not be loaded.",
                        supportingText: "Please try again.",
                        onRetry: load
                    )
                    .noraScreenPadding()
                } else if insights.isEmpty {
                    EmptyStateView(
                        symbolName: "bookmark",
                        title: "Nothing saved yet.",
                        supportingText: "Save an update from Today to keep it here."
                    )
                    .noraScreenPadding()
                } else {
                    List {
                        ForEach(insights) { insight in
                            Button {
                                router.showTopicDetail(insight.topicId)
                            } label: {
                                InsightRowView(insight: insight)
                            }
                            .buttonStyle(.plain)
                            .noraListRow()
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    remove(insight)
                                } label: {
                                    Label("Remove", systemImage: "bookmark.slash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .refreshable { load() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .environment(\.colorScheme, .dark)
        .navigationTitle("Saved")
        .task { load() }
    }

    private func load() {
        do {
            insights = try environment.savedInsightRepository.fetchAll()
            loadFailed = false
        } catch {
            loadFailed = true
        }
    }

    private func remove(_ insight: Insight) {
        do {
            try environment.savedInsightRepository.remove(id: insight.id)
            withAnimation { insights.removeAll { $0.id == insight.id } }
        } catch {
            loadFailed = true
        }
    }
}

#Preview("Saved insights") {
    NavigationStack { SavedView() }
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
}
