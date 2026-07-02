//
//  Item.swift
//  VoiceNotes
//
//  Created by Munavar on 02/07/26.
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
