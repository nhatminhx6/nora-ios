import SwiftUI

/// The message composer, anchored at the bottom of the screen like a
/// native Messages-style input rather than a floating action button.
struct AssistantComposerView: View {
    @Binding var text: String
    let isSending: Bool
    let onSend: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.sm) {
            TextField("Message Nora…", text: $text, axis: .vertical)
                .font(.noraBody)
                .lineLimit(1...5)
                .padding(.horizontal, Spacing.base)
                .padding(.vertical, Spacing.sm)
                .background(Color.noraSurface)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
                .focused($isFocused)
                .submitLabel(.send)
                .onSubmit(onSend)

            Button(action: onSend) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(canSend ? Color.noraAccent : Color.noraTextTertiary)
                    .clipShape(Circle())
            }
            .disabled(!canSend)
            .accessibilityLabel("Send message")
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.sm)
        .background(.bar)
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }
}

#Preview {
    AssistantComposerView(text: .constant("Tôi đang cân nhắc mua Mazda CX-5"), isSending: false, onSend: {})
}
