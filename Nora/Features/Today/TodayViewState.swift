import Foundation

/// Load state for the Today screen, driving skeleton, empty, error, or
/// loaded content.
enum TodayViewState: Equatable {
    case loading
    case loaded(Brief)
    case error
}

/// A short, rotating daily reflection question — kept separate from the
/// brief itself since it's about tuning Nora, not today's content.
struct ReflectionPrompt: Identifiable, Equatable {
    let id = UUID()
    let question: String
    let options: [String]
}

enum ReflectionPrompts {
    static let all: [ReflectionPrompt] = [
        ReflectionPrompt(question: "Is today's brief too much?", options: ["Just right", "A bit much"]),
        ReflectionPrompt(question: "Still interested in sci-fi movies?", options: ["Still am", "Not anymore"]),
        ReflectionPrompt(question: "Should tech news outrank job news?", options: ["Yes, do that", "Keep as is"]),
    ]

    static var random: ReflectionPrompt {
        all.randomElement() ?? all[0]
    }
}
