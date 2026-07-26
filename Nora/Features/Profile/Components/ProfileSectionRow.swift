import SwiftUI

/// One condensed section on the Profile screen: a title, a short summary
/// of what Nora knows, and an optional Edit action.
struct ProfileSectionRow: View {
    /// The summary line can be either dynamic model data (a raw `String`
    /// resolved as a catalog key with a proper-noun fallback) or a
    /// centrally-localized enum value (`LocalizedStringResource`).
    enum Summary {
        case content(String)
        case resource(LocalizedStringResource)
    }

    let title: LocalizedStringKey
    let symbolName: String
    let summary: Summary
    var onEdit: (() -> Void)?

    init(title: LocalizedStringKey, symbolName: String, summary: String, onEdit: (() -> Void)? = nil) {
        self.title = title
        self.symbolName = symbolName
        self.summary = .content(summary)
        self.onEdit = onEdit
    }

    init(title: LocalizedStringKey, symbolName: String, summary: LocalizedStringResource, onEdit: (() -> Void)? = nil) {
        self.title = title
        self.symbolName = symbolName
        self.summary = .resource(summary)
        self.onEdit = onEdit
    }

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.base) {
            Image(systemName: symbolName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.noraTextSecondary)
                .frame(width: 22)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.noraCardTitle)
                    .foregroundStyle(Color.noraTextPrimary)
                summaryText
                    .font(.noraSupporting)
                    .foregroundStyle(Color.noraTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            if let onEdit {
                Button("Edit", action: onEdit)
                    .buttonStyle(.noraTertiary)
                    .font(.noraSupporting.weight(.medium))
            }
        }
        .padding(.vertical, Spacing.sm)
    }

    private var summaryText: Text {
        switch summary {
        case .content(let value):
            Text(content: value)
        case .resource(let resource):
            Text(resource)
        }
    }
}

#Preview {
    List {
        ProfileSectionRow(title: "Work", symbolName: "briefcase", summary: "iOS Developer", onEdit: {})
    }
}
