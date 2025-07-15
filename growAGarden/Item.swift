//
//  Item.swift
//  growAGarden
//
//  Created by Tomoharu Hayakawa on 2025/07/15.
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
