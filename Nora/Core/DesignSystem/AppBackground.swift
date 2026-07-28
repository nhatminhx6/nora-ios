import SwiftUI

enum AppBackground: String, CaseIterable, Identifiable, Hashable {
    case rainyCity
    case mistyForest
    case moonlitCoast
    case mountainDusk

    var id: String { rawValue }

    var assetName: String {
        switch self {
        case .rainyCity: "WelcomeCity"
        case .mistyForest: "MistyForest"
        case .moonlitCoast: "MoonlitCoast"
        case .mountainDusk: "MountainDusk"
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .rainyCity: "Rainy City"
        case .mistyForest: "Misty Forest"
        case .moonlitCoast: "Moonlit Coast"
        case .mountainDusk: "Mountain Dusk"
        }
    }
}
