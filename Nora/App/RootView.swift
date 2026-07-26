import SwiftUI

/// Decides whether to show onboarding or the main tab experience, and hosts
/// the four-tab shell once onboarding is complete.
struct RootView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(LocalizationManager.self) private var localization
    @State private var router = AppRouter()
    @AppStorage("nora.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("nora.appearance") private var appearance: AppearanceOption = .system

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainTabView
            } else {
                OnboardingView(onComplete: {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        hasCompletedOnboarding = true
                    }
                })
            }
        }
        .environment(router)
        .environment(\.locale, localization.locale)
        // Rebuild the tree when the language changes so every `.task` reruns
        // and content is refetched in the newly selected language.
        .id(localization.language)
        .preferredColorScheme(colorScheme)
    }

    private var colorScheme: ColorScheme? {
        switch appearance {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    private var mainTabView: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack {
                TodayView()
            }
            .tabItem { Label { Text(AppTab.today.title) } icon: { Image(systemName: AppTab.today.symbolName) } }
            .tag(AppTab.today)

            NavigationStack {
                AssistantView()
            }
            .tabItem { Label { Text(AppTab.assistant.title) } icon: { Image(systemName: AppTab.assistant.symbolName) } }
            .tag(AppTab.assistant)

            NavigationStack(path: $router.followingPath) {
                FollowingView()
                    .navigationDestination(for: FollowingDestination.self) { destination in
                        switch destination {
                        case .topicDetail(let id):
                            TopicDetailView(topicId: id)
                        }
                    }
            }
            .tabItem { Label { Text(AppTab.following.title) } icon: { Image(systemName: AppTab.following.symbolName) } }
            .tag(AppTab.following)

            NavigationStack(path: $router.profilePath) {
                ProfileView()
                    .navigationDestination(for: ProfileDestination.self) { destination in
                        switch destination {
                        case .settings:
                            SettingsView()
                        }
                    }
            }
            .tabItem { Label { Text(AppTab.profile.title) } icon: { Image(systemName: AppTab.profile.symbolName) } }
            .tag(AppTab.profile)
        }
        .tint(.noraAccent)
    }
}

#Preview {
    RootView()
        .environment(AppEnvironment.preview())
}
