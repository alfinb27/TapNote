//
//  Item.swift
//  Tapnote
//
//  Created by Alfin Baby on 10/06/26.
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
