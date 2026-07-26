import SwiftUI

struct UpcomingSectionView: View {
    let items: [UpcomingItem]

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeaderView(title: "Upcoming")

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    row(for: item)
                    if index < items.count - 1 {
                        Divider().overlay(Color.noraDivider)
                    }
                }
            }
        }
    }

    private func row(for item: UpcomingItem) -> some View {
        HStack(spacing: Spacing.base) {
            Image(systemName: item.category.symbolName)
                .foregroundStyle(Color.noraAccent)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(content: item.title)
                    .font(.noraBody)
                    .foregroundStyle(Color.noraTextPrimary)
                Text(content: item.topicName)
                    .font(.noraCaption)
                    .foregroundStyle(Color.noraTextTertiary)
            }

            Spacer()

            Text(NoraDateFormat.countdown(to: item.date, locale: locale))
                .font(.noraSupporting.weight(.medium))
                .foregroundStyle(Color.noraTextSecondary)
        }
        .padding(.vertical, Spacing.sm)
    }
}

#Preview {
    UpcomingSectionView(items: PreviewData.todayBrief.upcomingItems)
        .noraScreenPadding()
}
