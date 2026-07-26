import Foundation

/// Centralized date/time formatting so screens never build their own
/// `DateFormatter` instances ad hoc. Every entry point takes a `locale` so
/// output follows the app's selected language, not just the device locale.
enum NoraDateFormat {
    /// The `.lproj` bundle matching `locale`, so word-based output resolves
    /// against the selected language's table. `String(localized:locale:)`
    /// alone only affects interpolation formatting, not table selection.
    private static func bundle(for locale: Locale) -> Bundle {
        if let code = locale.language.languageCode?.identifier,
           let path = Bundle.main.path(forResource: code, ofType: "lproj"),
           let languageBundle = Bundle(path: path) {
            return languageBundle
        }
        return .main
    }

    static func relativeDay(_ date: Date, calendar: Calendar = .current, locale: Locale = .autoupdatingCurrent) -> String {
        let bundle = bundle(for: locale)
        if calendar.isDateInToday(date) { return String(localized: "Today", bundle: bundle, locale: locale) }
        if calendar.isDateInTomorrow(date) { return String(localized: "Tomorrow", bundle: bundle, locale: locale) }
        if calendar.isDateInYesterday(date) { return String(localized: "Yesterday", bundle: bundle, locale: locale) }
        return date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).locale(locale))
    }

    static func time(_ date: Date, locale: Locale = .autoupdatingCurrent) -> String {
        date.formatted(.dateTime.hour().minute().locale(locale))
    }

    static func fullDate(_ date: Date, locale: Locale = .autoupdatingCurrent) -> String {
        date.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(locale))
    }

    static func relativeTimestamp(_ date: Date, now: Date = .now, locale: Locale = .autoupdatingCurrent) -> String {
        let bundle = bundle(for: locale)
        let interval = now.timeIntervalSince(date)
        if interval < 60 { return String(localized: "Just now", bundle: bundle, locale: locale) }
        if interval < 3600 { return String(localized: "\(Int(interval / 60))m ago", bundle: bundle, locale: locale) }
        if interval < 86400 { return String(localized: "\(Int(interval / 3600))h ago", bundle: bundle, locale: locale) }
        return relativeDay(date, locale: locale)
    }

    static func countdown(to date: Date, from now: Date = .now, locale: Locale = .autoupdatingCurrent) -> String {
        let bundle = bundle(for: locale)
        let interval = date.timeIntervalSince(now)
        if interval <= 0 { return String(localized: "Now", bundle: bundle, locale: locale) }
        let days = Int(interval / 86400)
        if days >= 1 { return String(localized: "In \(days)d", bundle: bundle, locale: locale) }
        let hours = Int(interval / 3600)
        if hours >= 1 { return String(localized: "In \(hours)h", bundle: bundle, locale: locale) }
        let minutes = max(1, Int(interval / 60))
        return String(localized: "In \(minutes)m", bundle: bundle, locale: locale)
    }
}
