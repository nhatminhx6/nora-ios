import SwiftUI

/// The languages Nora ships translations for, plus a "follow the system"
/// option. Raw values match the `.lproj` / String Catalog language codes.
enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case system
    case english = "en"
    case vietnamese = "vi"

    var id: String { rawValue }

    /// Explicit locale for an override, or `nil` when following the system.
    var locale: Locale? {
        switch self {
        case .system: nil
        case .english: Locale(identifier: "en")
        case .vietnamese: Locale(identifier: "vi")
        }
    }

    var titleKey: LocalizedStringKey {
        switch self {
        case .system: "language.system"
        case .english: "language.english"
        case .vietnamese: "language.vietnamese"
        }
    }
}

enum AppLanguagePreference {
    static var apiCode: String {
        let stored = UserDefaults.standard.string(forKey: "nora.language")
        if stored == AppLanguage.vietnamese.rawValue { return "vi" }
        if stored == AppLanguage.english.rawValue { return "en" }
        return Locale.autoupdatingCurrent.language.languageCode?.identifier == "vi" ? "vi" : "en"
    }
}

/// Single source of truth for the app's language. Drives both SwiftUI
/// `Text` (via the environment locale) and imperatively-resolved content
/// (via `string(_:)`), so an in-app switch updates every surface without a
/// relaunch.
@MainActor
@Observable
final class LocalizationManager {
    var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Self.storageKey) }
    }

    private static let storageKey = "nora.language"

    init() {
        let stored = UserDefaults.standard.string(forKey: Self.storageKey)
        language = stored.flatMap(AppLanguage.init) ?? .system
    }

    /// Locale used for content resolution and formatting. Falls back to the
    /// device locale when following the system.
    var locale: Locale {
        language.locale ?? .autoupdatingCurrent
    }

    /// The `.lproj` bundle for the selected language, or the main bundle when
    /// following the system. Looking strings up in an explicit language
    /// bundle guarantees the right translation table regardless of the
    /// process's preferred languages.
    private var bundle: Bundle {
        if let code = language.locale?.identifier,
           let path = Bundle.main.path(forResource: code, ofType: "lproj"),
           let languageBundle = Bundle(path: path) {
            return languageBundle
        }
        return .main
    }

    /// Resolve a localized value for dynamic content with static keys and
    /// interpolated arguments (e.g. "You're a \(profession)").
    func string(_ key: String.LocalizationValue) -> String {
        String(localized: key, bundle: bundle, locale: locale)
    }

    /// Resolve a runtime string as a catalog key against the selected
    /// language, falling back to the string itself (e.g. proper nouns).
    func localized(_ runtimeKey: String) -> String {
        bundle.localizedString(forKey: runtimeKey, value: runtimeKey, table: nil)
    }
}

extension Text {
    /// Display localizable dynamic content: resolves `value` as a String
    /// Catalog key against the environment locale, falling back to the raw
    /// string when there is no translation (e.g. proper nouns like "OCB").
    /// Use this for model-provided strings; use `Text("literal")` for
    /// static UI copy.
    init(content value: String) {
        self.init(LocalizedStringKey(value))
    }
}
