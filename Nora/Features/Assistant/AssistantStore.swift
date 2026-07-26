import Foundation

@MainActor
@Observable
final class AssistantStore {
    private(set) var messages: [ConversationMessage]
    var composerText: String = ""
    private(set) var isSending = false

    let quickActions = ["Track a new topic", "Summarize this week", "Adjust notifications"]

    private let assistantService: AssistantService
    private let topicRepository: TopicRepository

    init(environment: AppEnvironment) {
        self.assistantService = environment.assistantService
        self.topicRepository = environment.topicRepository
        self.messages = []
    }

    func send(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }

        composerText = ""
        let userMessage = ConversationMessage(role: .user, content: trimmed)
        messages.append(userMessage)
        isSending = true

        Task {
            let reply = try? await assistantService.send(message: trimmed, history: messages)
            if let reply {
                messages.append(reply)
                if let context = reply.extractedContext {
                    await createTopicIfNeeded(from: context, sourceMessage: trimmed)
                }
            }
            isSending = false
        }
    }

    func sendQuickReply(_ text: String) {
        send(text)
    }

    private func createTopicIfNeeded(from context: ExtractedContext, sourceMessage: String) async {
        guard let title = context.summaryLines.first else { return }
        let topic = Topic(
            name: title,
            category: .purchases,
            relationship: .considering,
            trackingRules: Array(context.summaryLines.dropFirst()),
            notificationMode: .dailyBrief,
            relevanceReason: sourceMessage
        )
        try? topicRepository.upsert(topic)
    }
}
