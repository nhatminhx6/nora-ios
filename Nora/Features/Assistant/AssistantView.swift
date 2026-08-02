import SwiftUI

/// The conversation surface. Deliberately not styled like a generic
/// chatbot: no avatar, no "AI Assistant" label, a minimal header, and a
/// composer that reads as a natural extension of the screen.
struct AssistantView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var store: AssistantStore?

    var body: some View {
        Group {
            if let store {
                content(store: store)
            } else {
                // A non-empty placeholder guarantees the view participates in
                // the lifecycle so `.task` fires and the store is created.
                // A bare `Group` collapses to `EmptyView` when the store is
                // nil, and `.task` never runs on an empty view.
                Color.clear
            }
        }
        .background { NoraHeroBackground() }
        .environment(\.colorScheme, .dark)
        .navigationTitle("Assistant")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Assistant unavailable",
            isPresented: Binding(
                get: { store?.errorMessage != nil },
                set: { if !$0 { store?.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(store?.errorMessage ?? "")
        }
        .task {
            if store == nil {
                store = AssistantStore(environment: environment)
            }
        }
    }

    private func content(store: AssistantStore) -> some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    if store.messages.isEmpty {
                        emptyState(store: store)
                    } else {
                        LazyVStack(alignment: .leading, spacing: Spacing.base) {
                            ForEach(store.messages) { message in
                                VStack(alignment: .leading, spacing: Spacing.sm) {
                                    MessageRowView(message: message)
                                    if let context = message.extractedContext {
                                        ExtractedContextCard(context: context, onQuickReply: store.sendQuickReply)
                                    }
                                }
                                .id(message.id)
                            }

                            if store.isSending {
                                HStack(spacing: Spacing.xs) {
                                    ProgressView().controlSize(.mini)
                                    Text("Nora is typing…")
                                        .font(.noraCaption)
                                        .foregroundStyle(Color.noraTextTertiary)
                                }
                            }
                        }
                        .noraScreenPadding()
                        .padding(.vertical, Spacing.base)
                    }
                }
                .onChange(of: store.messages.count) {
                    guard let last = store.messages.last else { return }
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            AssistantComposerView(
                text: Bindable(store).composerText,
                isSending: store.isSending,
                onSend: { store.send(store.composerText) }
            )
        }
    }

    private func emptyState(store: AssistantStore) -> some View {
        VStack(spacing: Spacing.xl) {
            Spacer(minLength: Spacing.xxl)
            VStack(spacing: Spacing.sm) {
                Text("What's on your mind?")
                    .font(.noraSectionTitle)
                    .foregroundStyle(Color.noraTextPrimary)
                Text("Tell Nora about your work, plans, or something you're considering.")
                    .font(.noraBody)
                    .foregroundStyle(Color.noraTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .noraScreenPadding()

            if !store.quickActions.isEmpty {
                QuickActionsBar(actions: store.quickActions, onTap: store.sendQuickReply)
            }
        }
    }
}

#Preview("Empty") {
    NavigationStack { AssistantView() }
        .environment(AppEnvironment.preview())
}
