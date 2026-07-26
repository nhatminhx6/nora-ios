import Foundation

enum ConversationRole: String, Codable, Hashable {
    case user
    case assistant
}

/// Structured context the assistant extracted from a user message, shown as
/// a compact confirmation card rather than folded silently into prose.
struct ExtractedContext: Codable, Equatable {
    var summaryLines: [String]
    var followUpQuestion: String?
    var quickReplies: [String]

    init(summaryLines: [String] = [], followUpQuestion: String? = nil, quickReplies: [String] = []) {
        self.summaryLines = summaryLines
        self.followUpQuestion = followUpQuestion
        self.quickReplies = quickReplies
    }
}

struct ConversationMessage: Identifiable, Codable, Equatable {
    var id: UUID
    var role: ConversationRole
    var content: String
    var createdAt: Date
    var suggestedReplies: [String]
    var extractedContext: ExtractedContext?

    init(
        id: UUID = UUID(),
        role: ConversationRole,
        content: String,
        createdAt: Date = .now,
        suggestedReplies: [String] = [],
        extractedContext: ExtractedContext? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
        self.suggestedReplies = suggestedReplies
        self.extractedContext = extractedContext
    }
}
