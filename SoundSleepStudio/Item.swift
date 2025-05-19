//
//  Item.swift
//  SoundSleepStudio
//
//  Created by Afga Ghifari on 19/05/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
