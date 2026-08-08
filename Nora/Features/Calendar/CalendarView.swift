import SwiftUI

struct CalendarView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var store: CalendarStore?
    @State private var isAddingEvent = false
    @AppStorage("nora.calendar.showLunar") private var showLunarCalendar = false

    var body: some View {
        Group {
            if let store {
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        monthHeader(store)
                        weekdayHeader
                        monthGrid(store)
                        selectedDayEvents(store)
                    }
                    .noraScreenPadding()
                    .padding(.bottom, Spacing.xxl)
                }
            } else {
                Color.clear
            }
        }
        .background { NoraHeroBackground() }
        .environment(\.colorScheme, .dark)
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showLunarCalendar.toggle()
                } label: {
                    Label("Lunar", systemImage: showLunarCalendar ? "moon.stars.fill" : "moon.stars")
                }
                .tint(showLunarCalendar ? .noraAccentBright : .white)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { isAddingEvent = true } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add event")
            }
        }
        .task {
            if store == nil {
                let newStore = CalendarStore(environment: environment)
                store = newStore
                newStore.load()
            }
        }
        .sheet(isPresented: $isAddingEvent) {
            if let store {
                AddCalendarEventSheet(date: store.selectedDate) { event in
                    Task { await store.add(event) }
                }
            }
        }
        .overlay {
            if let store, store.isScheduling {
                NoraLoadingOverlay(label: "Scheduling…")
            }
        }
    }

    private func monthHeader(_ store: CalendarStore) -> some View {
        HStack {
            Button { store.moveMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
                    .frame(width: TouchTarget.minimum, height: TouchTarget.minimum)
            }

            Spacer()

            Text(store.visibleMonth.formatted(.dateTime.month(.wide).year()))
                .font(.noraSectionTitle)

            Spacer()

            Button { store.moveMonth(by: 1) } label: {
                Image(systemName: "chevron.right")
                    .frame(width: TouchTarget.minimum, height: TouchTarget.minimum)
            }
        }
        .foregroundStyle(.white)
    }

    private var weekdayHeader: some View {
        let symbols = Calendar.current.veryShortStandaloneWeekdaySymbols
        return LazyVGrid(columns: columns, spacing: Spacing.sm) {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.noraCaption.weight(.semibold))
                    .foregroundStyle(Color.noraTextSecondary)
            }
        }
    }

    private func monthGrid(_ store: CalendarStore) -> some View {
        LazyVGrid(columns: columns, spacing: Spacing.sm) {
            ForEach(monthDates(for: store.visibleMonth), id: \.self) { date in
                if let date {
                    dayCell(date, store: store)
                } else {
                    Color.clear.frame(height: 58)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.noraGlassTeal, in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
    }

    private func dayCell(_ date: Date, store: CalendarStore) -> some View {
        let selected = Calendar.current.isDate(date, inSameDayAs: store.selectedDate)
        let hasEvents = !store.events(on: date).isEmpty

        return Button {
            store.selectedDate = date
            Haptics.play(.selection)
        } label: {
            VStack(spacing: 2) {
                Text(date.formatted(.dateTime.day()))
                    .font(.noraBody.weight(selected ? .bold : .regular))

                if showLunarCalendar {
                    Text(lunarDay(for: date))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(selected ? .white.opacity(0.84) : Color.noraAccentBright)
                } else {
                    Circle()
                        .fill(hasEvents ? Color.noraAccentBright : .clear)
                        .frame(width: 4, height: 4)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(
                selected ? Color.noraGlassSelected : Color.clear,
                in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
            )
            .overlay(alignment: .bottom) {
                if showLunarCalendar && hasEvents {
                    Circle().fill(Color.noraGlow).frame(width: 4, height: 4).padding(.bottom, 3)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func selectedDayEvents(_ store: CalendarStore) -> some View {
        let events = store.events(on: store.selectedDate)
        return VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text(store.selectedDate.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                    .font(.noraSectionTitle)
                Spacer()
                Button("Add event") { isAddingEvent = true }
                    .buttonStyle(.noraTertiary)
            }

            if events.isEmpty {
                Text("No events yet.")
                    .font(.noraBody)
                    .foregroundStyle(Color.noraTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .noraSurfaceCard()
            } else {
                ForEach(events) { event in
                    HStack(spacing: Spacing.md) {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(event.title).font(.noraCardTitle)
                            Text(event.isAllDay ? "All-day" : event.startDate.formatted(date: .omitted, time: .shortened))
                                .font(.noraSupporting)
                                .foregroundStyle(Color.noraTextSecondary)
                        }
                        Spacer()
                        Button(role: .destructive) { store.delete(event) } label: {
                            Image(systemName: "trash")
                        }
                    }
                    .noraSurfaceCard()
                }
            }
        }
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.xs), count: 7)

    private func monthDates(for month: Date) -> [Date?] {
        let calendar = Calendar.current
        guard
            let range = calendar.range(of: .day, in: .month, for: month),
            let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: month))
        else { return [] }

        let leading = (calendar.component(.weekday, from: firstDay) - calendar.firstWeekday + 7) % 7
        return Array(repeating: nil, count: leading)
            + range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: firstDay) }.map(Optional.some)
    }

    private func lunarDay(for date: Date) -> String {
        var lunar = Calendar(identifier: .chinese)
        lunar.locale = Locale(identifier: "vi_VN")
        let components = lunar.dateComponents([.day, .month], from: date)
        guard let day = components.day, let month = components.month else { return "" }
        return day == 1 ? "\(day)/\(month)" : "\(day)"
    }
}

#Preview {
    NavigationStack { CalendarView() }
        .environment(AppEnvironment.preview())
}
