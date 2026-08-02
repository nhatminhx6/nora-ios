import Foundation

/// Load state for the Today screen, driving skeleton, empty, error, or
/// loaded content.
enum TodayViewState: Equatable {
    case loading
    case loaded(Brief)
    case error
}

struct ReflectionPrompt: Identifiable, Equatable {
    let id = UUID()
    let question: String
    let options: [String]
}
