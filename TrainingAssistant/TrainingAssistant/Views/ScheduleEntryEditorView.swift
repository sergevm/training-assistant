//
//  ScheduleEntryEditorView.swift
//  TrainingAssistant
//
//  Add a weekly schedule entry (day + start hour) to a class. Duration is
//  always one hour. Rejects an entry that duplicates an existing day/hour.
//

import SwiftUI
import SwiftData

struct ScheduleEntryEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let trainingClass: TrainingClass

    /// All quarter-hour start times across the day, as minutes since midnight.
    private static let startTimeOptions: [Int] = Array(stride(from: 0, to: 24 * 60, by: 15))

    @State private var selectedDay: Weekday = .monday
    @State private var selectedMinuteOfDay: Int = 9 * 60 // 09:00
    @State private var showsDuplicateAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Day", selection: $selectedDay) {
                        ForEach(Weekday.allCases) { day in
                            Text(day.displayName).tag(day)
                        }
                    }

                    Picker("Start", selection: $selectedMinuteOfDay) {
                        ForEach(Self.startTimeOptions, id: \.self) { minuteOfDay in
                            Text(Self.timeLabel(minuteOfDay)).tag(minuteOfDay)
                        }
                    }
                } footer: {
                    Text("Each session lasts one hour.")
                }
            }
            .navigationTitle("Add Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addEntry() }
                }
            }
            .alert("Session Already Exists", isPresented: $showsDuplicateAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("This class already has a session on \(selectedDay.displayName) at that time.")
            }
        }
    }

    private func addEntry() {
        let hour = selectedMinuteOfDay / 60
        let minute = selectedMinuteOfDay % 60

        let isDuplicate = trainingClass.schedule.contains {
            $0.dayOfWeek == selectedDay.rawValue && $0.startHour == hour && $0.startMinute == minute
        }
        guard !isDuplicate else {
            showsDuplicateAlert = true
            return
        }

        let entry = ScheduleEntry(
            dayOfWeek: selectedDay.rawValue,
            startHour: hour,
            startMinute: minute
        )
        modelContext.insert(entry)
        // Appending maintains the inverse (entry.trainingClass); setting both
        // sides would double-link. Save now so the entry is durably persisted
        // before we navigate away.
        trainingClass.schedule.append(entry)
        try? modelContext.save()
        dismiss()
    }

    /// Locale-formatted label for a minutes-since-midnight value (e.g. "9:15 AM" or "09:15").
    private static func timeLabel(_ minuteOfDay: Int) -> String {
        var components = DateComponents()
        components.hour = minuteOfDay / 60
        components.minute = minuteOfDay % 60
        guard let date = Calendar.current.date(from: components) else {
            return String(format: "%02d:%02d", minuteOfDay / 60, minuteOfDay % 60)
        }
        return date.formatted(date: .omitted, time: .shortened)
    }
}

#Preview {
    ScheduleEntryEditorView(trainingClass: TrainingClass(name: "Puppy Class"))
        .modelContainer(for: [TrainingClass.self, ScheduleEntry.self, Combination.self], inMemory: true)
}
