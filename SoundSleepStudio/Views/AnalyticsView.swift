//
//  AnalyticsView.swift
//  SoundSleepStudio
//
//  Created by Wentao Guo on 22/05/25.
//

import Charts
import SwiftData
import SwiftUI

enum AnalyticsRange: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
}

struct AnalyticsView: View {
    // today session predicate and query
    static var todayPredicate: Predicate<HeartRateSession> {
        let today = Calendar.current.startOfDay(for: Date())
        return #Predicate { $0.startDate >= today }
    }

    @Query(filter: todayPredicate, sort: \.startDate) var todaySessions:
        [HeartRateSession]

    // 7 days session predicate and query
    static var weekPredicate: Predicate<HeartRateSession> {
        let week = Calendar.current.date(
            byAdding: .day, value: -6,
            to: Calendar.current.startOfDay(for: Date()))!
        return #Predicate { $0.startDate >= week }
    }

    @Query(filter: weekPredicate, sort: \.startDate) var weekSessions:
        [HeartRateSession]

    @State private var selectedRange: AnalyticsRange = .daily

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analytics")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.primary)

            Text("Heart Rate Logs")
                .font(.title3)
                .bold()
                .foregroundColor(.primary)

            // Picker for Range
            Picker("Range", selection: $selectedRange) {
                ForEach(AnalyticsRange.allCases, id: \.self) { range in
                    Text(range.rawValue)
                }
            }
            .pickerStyle(.segmented)

            switch selectedRange {
                
            //MARK: DAYILY ANAYLSIS PAGE
            case .daily:
                if todaySessions.isEmpty {
                    Text("No data, please start to use app, thanks").frame(
                        maxWidth: .infinity, alignment: .center)
                } else {
                    // Range info
                    Text("RANGE")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        // min bpm and max bpm
                        Text(
                            "\(Int(todaySessions[0].minBpm ?? 0))–\(Int(todaySessions[0].maxBpm ?? 0))"
                        )
                        .font(.title)
                        .foregroundColor(.primary)
                        Text("BPM")
                            .foregroundColor(.secondary)
                            .font(.title3)
                    }
                    // DATE
                    Text(
                        todaySessions[0].startDate.formatted(
                            .dateTime.day().month(.wide).year())
                    )
                    .foregroundColor(.gray)
                    .font(.subheadline)

                    // Chart, daily
                    Chart {
                        ForEach(
                            todaySessions[0].bpmRecords.sorted(by: {
                                $0.timestamp < $1.timestamp
                            })
                        ) { record in
                            PointMark(
                                x: .value("Time", record.timestamp),
                                y: .value("BPM", record.value)
                            )
                        }
                    }
                    .frame(height: 200)
                    .chartXScale(
                        domain: todaySessions[0]
                            .startDate...(todaySessions[0].endDate ?? Date())
                    )

                    .chartXAxis {
                        let start = todaySessions[0].startDate
                        let end = todaySessions[0].endDate ?? Date()
                        let interval = end.timeIntervalSince(start)

                        AxisMarks(values: [
                            start,
                            start.addingTimeInterval(interval * 0.25),
                            start.addingTimeInterval(interval * 0.5),
                            start.addingTimeInterval(interval * 0.75),
                            end,
                        ]) { value in
                            AxisTick()
                            AxisValueLabel(
                                format: .dateTime.hour().minute().second())
                        }
                    }
                    .chartYScale(domain: 50...125)

                    // Footer tip
                    //                    HStack(alignment: .top, spacing: 8) {
                    //                        Image(systemName: "lightbulb.fill")
                    //                            .foregroundColor(.yellow)
                    //                        Text(
                    //                            "You reach your resting heart rate at 01:34 AM, your body finally slowed down."
                    //                        )
                    //                        .font(.footnote)
                    //                        .foregroundColor(.primary)
                    //                    }
                    //                    .frame(maxWidth: .infinity)
                    //                    .padding()
                    //                    .background(Color(.darkGray).opacity(0.6))
                    //                    .cornerRadius(12)
                }
            
            //MARK: WEEKLY PAGE
            case .weekly:
                Text("2")
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        //        .preferredColorScheme(.dark)

    }
}
#Preview {
    AnalyticsView()
}
