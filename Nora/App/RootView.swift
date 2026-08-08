import SwiftUI

/// Decides whether to show onboarding or the main tab experience, and hosts
/// the Home experience once onboarding is complete.
struct RootView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(LocalizationManager.self) private var localization
    @Environment(\.scenePhase) private var scenePhase
    @State private var router = AppRouter()
    // Local cache for fast launch; refreshed from the backend whenever the session becomes active.
    @AppStorage("nora.hasCompletedOnboarding") private var onboardingCompleted = false
    @AppStorage("nora.lastHandledOnboardingRestartToken") private var lastHandledRestartToken = ""
    @AppStorage("nora.appearance") private var appearance: AppearanceOption = .system
    @State private var isResolvingOnboarding = true

    var body: some View {
        Group {
            if !environment.authSession.isAuthenticated {
                LoginView()
                    .transition(.opacity)
            } else if isResolvingOnboarding {
                NoraFullscreenLoadingView(label: "Preparing Nora for you…")
            } else if onboardingCompleted {
                mainTabView
            } else {
                OnboardingView(onComplete: {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        onboardingCompleted = true
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
        .task(id: environment.authSession.isAuthenticated) {
            await synchronizeOnboardingState()
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active, environment.authSession.isAuthenticated else { return }
            Task { await synchronizeOnboardingState() }
        }
    }

    private var colorScheme: ColorScheme? {
        switch appearance {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    @MainActor
    private func synchronizeOnboardingState() async {
        guard environment.authSession.isAuthenticated else {
            isResolvingOnboarding = false
            return
        }
        isResolvingOnboarding = true
        defer { isResolvingOnboarding = false }
        do {
            let serverState = try await environment.profileService.fetchOnboardingState()
            if let restartToken = serverState.restartToken,
               restartToken != lastHandledRestartToken {
                lastHandledRestartToken = restartToken
                onboardingCompleted = false
                return
            }
            // Completion is monotonic on-device: a stale or delayed backend
            // response must never send the user back through onboarding.
            onboardingCompleted = onboardingCompleted || serverState.isCompleted
        } catch {
            // Keep the last known local state when the server is temporarily unavailable.
        }
    }

    private var mainTabView: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack(path: $router.followingPath) {
                TodayView()
                    .navigationDestination(for: FollowingDestination.self) { destination in
                        switch destination {
                        case .topicDetail(let id):
                            TopicDetailView(topicId: id)
                        }
                    }
            }
            .tabItem { Label { Text(AppTab.today.title) } icon: { Image(systemName: AppTab.today.symbolName) } }
            .tag(AppTab.today)

            NavigationStack {
                SavedView()
            }
            .tabItem { Label { Text(AppTab.saved.title) } icon: { Image(systemName: AppTab.saved.symbolName) } }
            .tag(AppTab.saved)

            NavigationStack {
                CalendarView()
            }
            .tabItem { Label { Text(AppTab.calendar.title) } icon: { Image(systemName: AppTab.calendar.symbolName) } }
            .tag(AppTab.calendar)

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
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .environment(\.colorScheme, .dark)
    }
}

#Preview {
    RootView()
        .environment(AppEnvironment.preview())
}
