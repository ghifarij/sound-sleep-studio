//
//  Utilities.swift
//  SoundSleepStudio
//
//  Created by Wentao Guo on 02/06/25.
//

import Foundation

class Utilities {
    static func formattedRangeText(from sessions: [HeartRateSession]) -> String {
        guard let first = sessions.min(by: { $0.startDate < $1.startDate }),
              let last = sessions.max(by: { $0.startDate < $1.startDate }) else {
            return ""
        }


        return "\(first.startDate.formatted(.dateTime.day().month(.abbreviated))) - \(last.startDate.formatted(.dateTime.day().month(.abbreviated).year()))"
    }
    
    static func getMaxMinBpm(sessions: [HeartRateSession]) -> (
        min: Int, max: Int
    ) {
        var minB = 1000.0
        var maxB = -1000.0
        for i in sessions {
            minB = min(minB, i.minBpm ?? 0)
            maxB = max(maxB, i.maxBpm ?? 0)
        }
        return (Int(minB), Int(maxB))
    }

}
