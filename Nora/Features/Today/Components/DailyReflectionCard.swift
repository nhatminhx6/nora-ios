import SwiftUI

/// A very small, easy-to-dismiss prompt that helps Nora calibrate — never
/// a modal, never blocking.
struct DailyReflectionCard: View {
    let prompt: ReflectionPrompt
    let hasAnswered: Bool
    let onAnswer: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(content: hasAnswered ? "Thanks for your feedback." : prompt.question)
                .font(.noraSupporting)
                .foregroundStyle(Color.noraTextSecondary)

            if !hasAnswered {
                HStack(spacing: Spacing.sm) {
                    ForEach(prompt.options, id: \.self) { option in
                        ChipView(title: option, action: { onAnswer(option) })
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .noraElevatedCard()
        .animation(.easeInOut(duration: 0.25), value: hasAnswered)
    }
}

#Preview {
    DailyReflectionCard(prompt: ReflectionPrompts.all[0], hasAnswered: false, onAnswer: { _ in })
        .noraScreenPadding()
}
