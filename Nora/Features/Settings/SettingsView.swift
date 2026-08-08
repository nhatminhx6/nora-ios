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
    @AppStorage("nora.background") private var appBackground: AppBackground = .rainyCity
    @State private var dailyBriefTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? .now

    var body: some View {
        Group {
            if let store, store.isLoading {
                NoraFullscreenLoadingView(label: "Loading your settings…")
            } else if let store, let profile = store.profile {
                form(store: store, profile: profile)
            } else {
                // Keep the view non-empty so `.task` fires and creates the
                // store; a bare `Group` collapses to `EmptyView` when nil.
                Color.clear
            }
        }
        .background { NoraHeroBackground() }
        .environment(\.colorScheme, .dark)
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
        .overlay {
            if let store, store.isSaving {
                NoraLoadingOverlay(label: "Saving…")
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
            .listRowBackground(Color.noraGlassTeal)
            .listRowSeparatorTint(.white.opacity(0.14))

            Section("Appearance") {
                Picker("Theme", selection: $appearance) {
                    ForEach(AppearanceOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }
            .listRowBackground(Color.noraGlassWarm)

            Section("Background") {
                BackgroundPicker(selection: $appBackground)
            }
            .listRowInsets(EdgeInsets(top: Spacing.sm, leading: 0, bottom: Spacing.md, trailing: 0))
            .listRowBackground(Color.clear)

            Section("Language") {
                Picker("Language", selection: Bindable(localization).language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.titleKey).tag(language)
                    }
                }
            }
            .listRowBackground(Color.noraGlassTeal)

            Section("Privacy & data") {
                NavigationLink("Privacy") { PlaceholderInfoView(title: "Privacy", text: "Nora only uses what you share to personalize your brief. Nothing is sold to third parties.") }
                NavigationLink("Data controls") { PlaceholderInfoView(title: "Data controls", text: "Export or delete your data, or reset personalization from your Profile.") }
                NavigationLink("Sources") { PlaceholderInfoView(title: "Sources", text: "Nora draws from market data providers, sports schedules, travel and pricing feeds, and release calendars.") }
            }
            .listRowBackground(Color.noraGlassWarm)
            .listRowSeparatorTint(.white.opacity(0.14))

            Section("Account") {
                NavigationLink("Subscription") { PlaceholderInfoView(title: "Subscription", text: "You're on the free plan. Upgrade for real-time alerts across every topic.") }
                NavigationLink("About") { PlaceholderInfoView(title: "About Nora", text: "Nora version 1.0 — a personal brief built around your life.") }
            }
            .listRowBackground(Color.noraGlassTeal)
            .listRowSeparatorTint(.white.opacity(0.14))
        }
        .scrollContentBackground(.hidden)
    }
}

private struct BackgroundPicker: View {
    @Binding var selection: AppBackground

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.md) {
                ForEach(AppBackground.allCases) { background in
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selection = background
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Image(background.assetName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 112, height: 148)
                                .clipped()
                                .overlay(alignment: .topTrailing) {
                                    if selection == background {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 22, weight: .semibold))
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(Color.noraAccent, Color.noraGlassTeal)
                                            .padding(Spacing.sm)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                                        .stroke(
                                            selection == background ? Color.noraAccent : .white.opacity(0.22),
                                            lineWidth: selection == background ? 2 : 1
                                        )
                                }

                            Text(background.title)
                                .font(.noraSupporting)
                                .fontWeight(selection == background ? .semibold : .regular)
                                .foregroundStyle(selection == background ? Color.noraAccent : .white.opacity(0.82))
                                .lineLimit(1)
                        }
                        .frame(width: 112, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selection == background ? .isSelected : [])
                }
            }
            .padding(.horizontal, Spacing.md)
        }
        .scrollIndicators(.hidden)
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
