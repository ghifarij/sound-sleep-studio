//
//  AnalyticsView.swift
//  SoundSleepStudio
//
//  Created by Wentao Guo on 22/05/25.
//

import Charts
import SwiftUI

enum AnalyticsRange: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
}

struct AnalyticsView: View {
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

            // Range info
            Text("RANGE")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                Text("60–78")
                    .font(.title)
                    .foregroundColor(.primary)
                Text("BPM")
                    .foregroundColor(.secondary)
                    .font(.title3)
            }

            Text("27 March 2025")
                .foregroundColor(.gray)
                .font(.subheadline)

            // Chart
            Chart {
                ForEach(0..<6, id: \.self) { i in
                    PointMark(
                        x: .value("Time", i),
                        y: .value("BPM", Int.random(in: 60...78))
                    )
                }
            }
            .frame(height: 200)
            .chartYScale(domain: 50...125)
            .foregroundStyle(.purple)
            .chartXAxis {
                AxisMarks(position: .bottom)
            }

            // Footer tip
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text(
                    "You reach your resting heart rate at 01:34 AM, your body finally slowed down."
                )
                .font(.footnote)
                .foregroundColor(.primary)
            }
            .padding()
            .background(Color(.darkGray).opacity(0.6))
            .cornerRadius(12)
        }
        .padding()
    
        .preferredColorScheme(.dark)

    }
}
#Preview {
    AnalyticsView()
}
