import SwiftUI

/// Lightweight sheet for adding a topic manually. Kept intentionally short
/// — the primary way to add topics is conversational, through Assistant.
struct AddTopicSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var category: TopicCategory = .other
    @State private var relationship: TopicRelationship = .learning

    let onAdd: (String, TopicCategory, TopicRelationship) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. OCB, Liverpool FC", text: $name)
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(TopicCategory.allCases) { category in
                            Text(category.title).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Relationship") {
                    Picker("Relationship", selection: $relationship) {
                        ForEach(TopicRelationship.allCases) { relationship in
                            Text(relationship.label).tag(relationship)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Add topic")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(name.trimmingCharacters(in: .whitespaces), category, relationship)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddTopicSheet(onAdd: { _, _, _ in })
}
