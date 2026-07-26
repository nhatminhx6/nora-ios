import SwiftUI

/// Generic sheet for editing a list of short text items (interests, goals)
/// — add, remove, and save, without needing a bespoke form per section.
struct EditListSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var items: [String]
    @State private var newItem: String = ""
    let title: LocalizedStringKey
    let onSave: ([String]) -> Void

    init(title: LocalizedStringKey, items: [String], onSave: @escaping ([String]) -> Void) {
        self.title = title
        self._items = State(initialValue: items)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(items, id: \.self) { item in
                        Text(content: item)
                    }
                    .onDelete { indexSet in
                        items.remove(atOffsets: indexSet)
                    }
                }

                Section {
                    HStack {
                        TextField("Add new", text: $newItem)
                        Button("Add") {
                            let trimmed = newItem.trimmingCharacters(in: .whitespaces)
                            guard !trimmed.isEmpty else { return }
                            items.append(trimmed)
                            newItem = ""
                        }
                        .disabled(newItem.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(items)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    EditListSheet(title: "Interests", items: ["SwiftUI", "Liverpool FC"], onSave: { _ in })
}
