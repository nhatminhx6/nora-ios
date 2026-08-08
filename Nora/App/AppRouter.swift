import SwiftUI

/// The top-level destinations. Order here defines tab order.
enum AppTab: Int, CaseIterable, Identifiable, Hashable {
    case today
    case saved
    case following
    case calendar
    case profile

    var id: Int { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .today: "Today"
        case .saved: "Saved"
        case .following: "Following"
        case .calendar: "Calendar"
        case .profile: "Profile"
        }
    }

    var symbolName: String {
        switch self {
        case .today: "sun.max"
        case .saved: "bookmark"
        case .following: "eye"
        case .calendar: "calendar"
        case .profile: "person.crop.circle"
        }
    }
}

/// Destinations pushed within the Following tab's navigation stack.
enum FollowingDestination: Hashable {
    case topicDetail(UUID)
}

/// Destinations pushed within the Profile tab's navigation stack.
enum ProfileDestination: Hashable {
    case settings
}

/// Owns per-tab navigation state so pushing a topic detail, switching tabs,
/// and coming back preserves each stack independently.
@MainActor
@Observable
final class AppRouter {
    var selectedTab: AppTab = .today
    var followingPath = NavigationPath()
    var profilePath = NavigationPath()

    func showTopicDetail(_ topicId: UUID) {
        selectedTab = .following
        followingPath.append(FollowingDestination.topicDetail(topicId))
    }

    func showSettings() {
        selectedTab = .profile
        profilePath.append(ProfileDestination.settings)
    }
}
