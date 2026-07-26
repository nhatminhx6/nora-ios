import SwiftUI

/// A compact, structured confirmation of what Nora just understood from
/// the user's message, plus at most one follow-up question. Never a long
/// form — just enough structure to feel precise.
struct ExtractedContextCard: View {
    let context: ExtractedContext
    let onQuickReply: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            if !context.summaryLines.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Noted")
                        .font(.noraEyebrow)
                        .foregroundStyle(Color.noraTextSecondary)

                    ForEach(context.summaryLines, id: \.self) { line in
                        HStack(alignment: .top, spacing: Spacing.sm) {
                            Circle()
                                .fill(Color.noraTextTertiary)
                                .frame(width: 4, height: 4)
                                .padding(.top, 8)
                            Text(content: line)
                                .font(.noraSupporting)
                                .foregroundStyle(Color.noraTextPrimary)
                        }
                    }
                }
            }

            if let question = context.followUpQuestion {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(content: question)
                        .font(.noraCardTitle)
                        .foregroundStyle(Color.noraTextPrimary)

                    FlowLayout(spacing: Spacing.sm) {
                        ForEach(context.quickReplies, id: \.self) { reply in
                            ChipView(title: reply, action: { onQuickReply(reply) })
                        }
                    }
                }
            }
        }
        .noraSurfaceCard()
    }
}

#Preview {
    ExtractedContextCard(
        context: ExtractedContext(
            summaryLines: ["Mazda CX-5", "Dự kiến mua trong 6 tháng", "Theo dõi giá, khuyến mãi, phiên bản mới"],
            followUpQuestion: "Anh đang quan tâm phiên bản nào?",
            quickReplies: ["Bản 2.0L Premium", "Bản 2.5L AWD"]
        ),
        onQuickReply: { _ in }
    )
    .noraScreenPadding()
}
