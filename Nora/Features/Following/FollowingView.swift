import SwiftUI

struct FollowingView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @State private var store: FollowingStore?
    @State private var isAddingTopic = false

    var body: some View {
        Group {
            if let store {
                content(store: store)
            } else {
                // Keep the view non-empty so `.task` fires and creates the
                // store; a bare `Group` collapses to `EmptyView` when nil.
                Color.clear
            }
        }
        .background { NoraHeroBackground() }
        .environment(\.colorScheme, .dark)
        .navigationTitle("Following")
        .task {
            if store == nil {
                let newStore = FollowingStore(environment: environment)
                store = newStore
                newStore.load()
            }
        }
        .sheet(isPresented: $isAddingTopic) {
            if let store {
                AddTopicSheet(onAdd: store.addTopic)
            }
        }
    }

    @ViewBuilder
    private func content(store: FollowingStore) -> some View {
        if store.isEmpty {
            EmptyStateView(
                symbolName: "sparkle.magnifyingglass",
                title: "Start with something already on your mind.",
                suggestions: ["A company you follow", "A team you support", "A trip you are planning", "A skill you are learning"],
                onSuggestionTapped: { _ in isAddingTopic = true }
            )
            .toolbar { addButton }
        } else {
            List {
                ForEach(store.groupedTopics) { group in
                    Section {
                        ForEach(group.topics) { topic in
                            Button {
                                router.showTopicDetail(topic.id)
                            } label: {
                                TopicRowView(topic: topic)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.delete(topic)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button {
                                    store.togglePause(topic)
                                } label: {
                                    Label(
                                        topic.status == .active ? "Pause" : "Resume",
                                        systemImage: topic.status == .active ? "pause" : "play"
                                    )
                                }
                                .tint(Color.noraAccent)
                            }
                        }
                    } header: {
                        Text(group.category.title)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .searchable(text: Bindable(store).searchText, prompt: "Search topics")
            .toolbar {
                addButton
                ToolbarItem(placement: .topBarLeading) {
                    Picker("Filter", selection: Bindable(store).filter) {
                        ForEach(FollowingFilter.allCases) { filter in
                            Text(filter.title).tag(filter)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }

    private var addButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isAddingTopic = true
            } label: {
                Image(systemName: "plus")
            }
            .accessibilityLabel("Add topic")
        }
    }
}

#Preview {
    NavigationStack { FollowingView() }
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
}
