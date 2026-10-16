import Foundation
import Observation

/// Persists completed focus sessions and derives simple stats for the
/// History tab's chart. Backed by UserDefaults + JSON for this demo —
/// swap for SwiftData/Core Data if the history grows large.
@Observable
final class HistoryStore {
    private(set) var records: [PomodoroSessionRecord] = []

    private let key = "focusflow.history.records"
    private let defaults = UserDefaults.standard

    init() {
        load()
    }

    func record(_ record: PomodoroSessionRecord) {
        records.append(record)
        save()
    }

    func totalFocusMinutes(on date: Date) -> Int {
        let calendar = Calendar.current
        return records
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .reduce(0) { $0 + Int($1.duration / 60) }
    }

    /// Minutes of focus time for each of the last 7 days, oldest first —
    /// ready to feed straight into a SwiftUI `Chart`.
    func last7Days() -> [(date: Date, minutes: Int)] {
        let calendar = Calendar.current
        return (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            return (day, totalFocusMinutes(on: day))
        }
    }

    private func load() {
        guard
            let data = defaults.data(forKey: key),
            let decoded = try? JSONDecoder().decode([PomodoroSessionRecord].self, from: data)
        else { return }
        records = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        defaults.set(data, forKey: key)
    }
}
