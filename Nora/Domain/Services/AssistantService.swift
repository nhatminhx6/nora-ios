import Foundation

/// Drives the Assistant conversation: sends a user message and returns
/// Nora's structured reply, including any context extracted for the
/// profile (e.g. a new purchase intent becoming a tracked topic).
protocol AssistantService: Sendable {
    func send(message: String, history: [ConversationMessage]) async throws -> ConversationMessage
}

struct LiveAssistantService: AssistantService {
    private let client: APIClient

    init(client: APIClient = APIClient()) { self.client = client }

    func send(message: String, history: [ConversationMessage]) async throws -> ConversationMessage {
        try await client.send(
            "assistant/messages",
            method: "POST",
            body: AssistantRequest(message: message, history: history)
        )
    }
}

private struct AssistantRequest: Encodable {
    let message: String
    let history: [ConversationMessage]
}

actor MockAssistantService: AssistantService {
    func send(message: String, history: [ConversationMessage]) async throws -> ConversationMessage {
        try await Task.sleep(for: .milliseconds(600))

        let lowercased = message.lowercased()
        if lowercased.contains("mazda") || lowercased.contains("mua xe") || lowercased.contains("cx-5") {
            return ConversationMessage(
                role: .assistant,
                content: "Got it — I've noted your purchase intent.",
                suggestedReplies: ["2.0L Premium", "2.5L AWD", "Not sure yet"],
                extractedContext: ExtractedContext(
                    summaryLines: [
                        "Mazda CX-5",
                        "Planning to buy within 6 months",
                        "Tracking price, promotions, new trims, and ownership costs",
                    ],
                    followUpQuestion: "Which trim are you interested in?",
                    quickReplies: ["2.0L Premium", "2.5L AWD", "Not sure yet"]
                )
            )
        }

        return ConversationMessage(
            role: .assistant,
            content: "Got it. Nora will keep watching and flag anything worth your attention.",
            suggestedReplies: ["Thanks", "Track something else"]
        )
    }
}
