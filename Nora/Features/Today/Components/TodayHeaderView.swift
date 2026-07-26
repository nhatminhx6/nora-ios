import SwiftUI

/// Greeting, date, and the one-line "what's today about" summary shown at
/// the very top of the Today screen.
struct TodayHeaderView: View {
    let displayName: String
    let headline: String
    let date: Date

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            (Text(content: greeting) + Text(verbatim: ", \(displayName)"))
                .font(.noraSupporting)
                .foregroundStyle(Color.noraTextSecondary)

            Text(NoraDateFormat.fullDate(date, locale: locale))
                .font(.noraCaption)
                .foregroundStyle(Color.noraTextTertiary)

            Text(content: headline)
                .font(.noraLargeTitle)
                .foregroundStyle(Color.noraTextPrimary)
                .padding(.top, Spacing.xs)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<18: return "Good afternoon"
        default: return "Good evening"
        }
    }
}

#Preview {
    TodayHeaderView(displayName: "Minh", headline: "3 things worth your attention today.", date: .now)
        .noraScreenPadding()
}
