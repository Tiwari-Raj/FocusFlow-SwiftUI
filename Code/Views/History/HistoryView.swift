import SwiftUI
import Charts

struct HistoryView: View {
    @Environment(HistoryStore.self) private var historyStore

    private var weekData: [(date: Date, minutes: Int)] {
        historyStore.last7Days()
    }

    private var totalMinutesThisWeek: Int {
        weekData.reduce(0) { $0 + $1.minutes }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Last 7 Days") {
                    Chart(weekData, id: \.date) { entry in
                        BarMark(
                            x: .value("Day", entry.date, unit: .day),
                            y: .value("Minutes", entry.minutes)
                        )
                        .foregroundStyle(Color.accentColor.gradient)
                        .cornerRadius(4)
                    }
                    .frame(height: 180)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in
                            AxisValueLabel(format: .dateTime.weekday(.narrow))
                        }
                    }
                }

                Section {
                    HStack(spacing: 12) {
                        StatCardView(title: "This Week", value: "\(totalMinutesThisWeek) min", systemImage: "clock.fill")
                        StatCardView(title: "Sessions", value: "\(historyStore.records.count)", systemImage: "checkmark.circle.fill")
                    }
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 4)
                    .listRowBackground(Color.clear)
                }

                Section("Recent Sessions") {
                    if historyStore.records.isEmpty {
                        ContentUnavailableView(
                            "No sessions yet",
                            systemImage: "moon.zzz",
                            description: Text("Complete a focus session to see it here.")
                        )
                    } else {
                        ForEach(historyStore.records.sorted { $0.date > $1.date }.prefix(20)) { record in
                            HStack {
                                Image(systemName: record.phase.systemImage)
                                    .foregroundStyle(record.phase.accentColor)
                                VStack(alignment: .leading) {
                                    Text(record.phase.title)
                                        .font(.subheadline.weight(.medium))
                                    Text(record.date, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(Int(record.duration / 60)) min")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}
