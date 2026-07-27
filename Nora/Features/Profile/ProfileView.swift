import SwiftUI

private enum ProfileEditTarget: Identifiable {
    case profession
    case interests
    case goals

    var id: Int {
        switch self {
        case .profession: 0
        case .interests: 1
        case .goals: 2
        }
    }
}

struct ProfileView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @State private var store: ProfileStore?
    @State private var editTarget: ProfileEditTarget?
    @State private var professionDraft: String = ""

    var body: some View {
        Group {
            if let store, let profile = store.profile {
                content(store: store, profile: profile)
            } else {
                // Keep the view non-empty so `.task` fires and creates the
                // store; a bare `Group` collapses to `EmptyView` when nil.
                Color.clear
            }
        }
        .background { NoraHeroBackground() }
        .environment(\.colorScheme, .dark)
        .navigationTitle("Profile")
        .task {
            if store == nil {
                let newStore = ProfileStore(environment: environment)
                store = newStore
                await newStore.load()
            }
        }
        .sheet(item: $editTarget) { target in
            if let store, let profile = store.profile {
                sheet(for: target, store: store, profile: profile)
            }
        }
    }

    private func content(store: ProfileStore, profile: UserProfile) -> some View {
        List {
            Section {
                UnderstandingSummaryCard(
                    summary: store.understandingSummary,
                    onCorrect: { editTarget = .interests },
                    onAddContext: { editTarget = .goals },
                    onReset: { Task { await store.resetPersonalization() } }
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            Section("About") {
                ProfileSectionRow(
                    title: "Work",
                    symbolName: "briefcase",
                    summary: profile.profession ?? "Not set yet",
                    onEdit: { editTarget = .profession }
                )

                ProfileSectionRow(
                    title: "Investments",
                    symbolName: "chart.line.uptrend.xyaxis",
                    summary: store.investmentTopics.isEmpty ? "Nothing tracked yet" : store.localizedInvestmentNames
                )

                ProfileSectionRow(
                    title: "Interests",
                    symbolName: "sparkle",
                    summary: profile.interests.isEmpty ? "Not set yet" : store.localizedInterests,
                    onEdit: { editTarget = .interests }
                )

                ProfileSectionRow(
                    title: "Plans",
                    symbolName: "flag",
                    summary: profile.goals.isEmpty ? "Not set yet" : store.localizedGoals,
                    onEdit: { editTarget = .goals }
                )
            }
            .listRowBackground(Color.noraGlassTeal)
            .listRowSeparatorTint(.white.opacity(0.14))

            Section("Behavior") {
                ProfileSectionRow(
                    title: "Notifications",
                    symbolName: "bell",
                    summary: profile.notificationPreference.title
                )

                NavigationLink(value: ProfileDestination.settings) {
                    Label("Settings", systemImage: "gearshape")
                        .font(.noraBody)
                        .foregroundStyle(Color.noraTextPrimary)
                }
            }
            .listRowBackground(Color.noraGlassWarm)
            .listRowSeparatorTint(.white.opacity(0.14))
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private func sheet(for target: ProfileEditTarget, store: ProfileStore, profile: UserProfile) -> some View {
        switch target {
        case .profession:
            ProfessionEditSheet(initialValue: profile.profession ?? "") { newValue in
                store.updateProfession(newValue)
            }
        case .interests:
            EditListSheet(title: "Interests", items: profile.interests, onSave: store.updateInterests)
        case .goals:
            EditListSheet(title: "Plans", items: profile.goals, onSave: store.updateGoals)
        }
    }
}

private struct ProfessionEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var value: String
    let onSave: (String) -> Void

    init(initialValue: String, onSave: @escaping (String) -> Void) {
        self._value = State(initialValue: initialValue)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("e.g. iOS Developer", text: $value)
                    .listRowBackground(Color.noraGlassTeal)
            }
            .scrollContentBackground(.hidden)
            .background { NoraHeroBackground() }
            .environment(\.colorScheme, .dark)
            .navigationTitle("Work")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(value)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack { ProfileView() }
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
}
