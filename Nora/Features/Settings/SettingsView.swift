import SwiftUI

enum AppearanceOption: String, CaseIterable, Identifiable, Hashable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}

struct SettingsView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(LocalizationManager.self) private var localization
    @State private var store: SettingsStore?
    @AppStorage("nora.appearance") private var appearance: AppearanceOption = .system
    @State private var dailyBriefTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? .now

    var body: some View {
        Group {
            if let store, let profile = store.profile {
                form(store: store, profile: profile)
            } else {
                // Keep the view non-empty so `.task` fires and creates the
                // store; a bare `Group` collapses to `EmptyView` when nil.
                Color.clear
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if store == nil {
                let newStore = SettingsStore(environment: environment)
                store = newStore
                await newStore.load()
                if let profile = newStore.profile {
                    dailyBriefTime = Calendar.current.date(from: profile.dailyBriefTime) ?? .now
                }
            }
        }
    }

    private func form(store: SettingsStore, profile: UserProfile) -> some View {
        Form {
            Section("Notifications") {
                Picker("Intensity", selection: Binding(
                    get: { profile.notificationPreference },
                    set: { store.updateIntensity($0) }
                )) {
                    ForEach(NotificationIntensity.allCases) { intensity in
                        Text(intensity.title).tag(intensity)
                    }
                }

                DatePicker(
                    "Daily brief time",
                    selection: $dailyBriefTime,
                    displayedComponents: .hourAndMinute
                )
                .onChange(of: dailyBriefTime) { _, newValue in
                    let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                    store.updateDailyBriefTime(components)
                }
            }

            Section("Appearance") {
                Picker("Theme", selection: $appearance) {
                    ForEach(AppearanceOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Language") {
                Picker("Language", selection: Bindable(localization).language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.titleKey).tag(language)
                    }
                }
            }

            Section("Privacy & data") {
                NavigationLink("Privacy") { PlaceholderInfoView(title: "Privacy", text: "Nora only uses what you share to personalize your brief. Nothing is sold to third parties.") }
                NavigationLink("Data controls") { PlaceholderInfoView(title: "Data controls", text: "Export or delete your data, or reset personalization from your Profile.") }
                NavigationLink("Sources") { PlaceholderInfoView(title: "Sources", text: "Nora draws from market data providers, sports schedules, travel and pricing feeds, and release calendars.") }
            }

            Section("Account") {
                NavigationLink("Subscription") { PlaceholderInfoView(title: "Subscription", text: "You're on the free plan. Upgrade for real-time alerts across every topic.") }
                NavigationLink("About") { PlaceholderInfoView(title: "About Nora", text: "Nora version 1.0 — a personal brief built around your life.") }
            }
        }
    }
}

private struct PlaceholderInfoView: View {
    let title: LocalizedStringKey
    let text: LocalizedStringKey

    var body: some View {
        ScrollView {
            Text(text)
                .font(.noraBody)
                .foregroundStyle(Color.noraTextSecondary)
                .noraScreenPadding()
                .padding(.top, Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { SettingsView() }
        .environment(AppEnvironment.preview())
}
