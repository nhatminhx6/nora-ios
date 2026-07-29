import SwiftUI

struct AddCalendarEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var notes = ""
    @State private var startDate: Date
    @State private var isAllDay = false
    @State private var reminderMinutes = 30

    let onSave: (CalendarEvent) -> Void

    init(date: Date, onSave: @escaping (CalendarEvent) -> Void) {
        let defaultDate = Calendar.current.date(
            bySettingHour: 9,
            minute: 0,
            second: 0,
            of: date
        ) ?? date
        _startDate = State(initialValue: defaultDate)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Event") {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                .listRowBackground(Color.noraGlassTeal)

                Section("When") {
                    Toggle("All-day", isOn: $isAllDay)
                    DatePicker(
                        "Starts",
                        selection: $startDate,
                        displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                    )
                }
                .listRowBackground(Color.noraGlassWarm)

                Section("Reminder") {
                    Picker("Remind me", selection: $reminderMinutes) {
                        Text("At event time").tag(0)
                        Text("10 minutes before").tag(10)
                        Text("30 minutes before").tag(30)
                        Text("1 hour before").tag(60)
                        Text("1 day before").tag(1_440)
                    }
                }
                .listRowBackground(Color.noraGlassTeal)
            }
            .scrollContentBackground(.hidden)
            .background { NoraHeroBackground() }
            .environment(\.colorScheme, .dark)
            .navigationTitle("New event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSave(
                            CalendarEvent(
                                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                                startDate: startDate,
                                isAllDay: isAllDay,
                                reminderMinutes: reminderMinutes
                            )
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
