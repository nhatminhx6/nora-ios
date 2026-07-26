import SwiftUI

struct TopicRowView: View {
    let topic: Topic

    var body: some View {
        HStack(spacing: Spacing.base) {
            VStack(alignment: .leading, spacing: 3) {
                Text(content: topic.name)
                    .font(.noraCardTitle)
                    .foregroundStyle(Color.noraTextPrimary)
                    .opacity(topic.status == .paused ? 0.5 : 1)

                Text(topic.relationship.label)
                    .font(.noraSupporting)
                    .foregroundStyle(Color.noraTextSecondary)
            }

            Spacer()

            HStack(spacing: Spacing.sm) {
                if topic.status == .paused {
                    Text("Paused")
                        .font(.noraCaption.weight(.medium))
                        .foregroundStyle(Color.noraTextTertiary)
                }

                Image(systemName: topic.notificationMode.symbolName)
                    .font(.system(size: 14))
                    .foregroundStyle(topic.priority == .high ? Color.noraAccent : Color.noraTextTertiary)
            }
        }
        .padding(.vertical, Spacing.xs)
        .contentShape(Rectangle())
    }
}

#Preview {
    List {
        TopicRowView(topic: PreviewData.topicOCB)
        TopicRowView(topic: PreviewData.topicLiverpool)
    }
}
