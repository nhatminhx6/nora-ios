import SwiftUI

/// A single message in the conversation. User messages are right-aligned
/// with a soft tint; Nora's replies read as plain text on the background —
/// deliberately understated so the screen never feels like a generic
/// chatbot.
struct MessageRowView: View {
    let message: ConversationMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: Spacing.xxl) }

            messageText
                .font(.noraBody)
                .foregroundStyle(message.role == .user ? .white : Color.noraTextPrimary)
                .padding(.horizontal, Spacing.base)
                .padding(.vertical, Spacing.sm)
                .background(message.role == .user ? Color.noraAccent : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))

            if message.role == .assistant { Spacer(minLength: Spacing.xxl) }
        }
    }

    /// User messages are shown verbatim (their own words, never localized);
    /// Nora's replies resolve through the catalog via `Text(content:)`.
    private var messageText: Text {
        message.role == .user
            ? Text(message.content)
            : Text(content: message.content)
    }
}

#Preview {
    VStack(spacing: Spacing.sm) {
        MessageRowView(message: PreviewData.conversation[0])
        MessageRowView(message: PreviewData.conversation[1])
    }
    .noraScreenPadding()
}
