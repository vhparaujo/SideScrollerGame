//
//  KeymapModel.swift
//  SideScrollerGame
//
//  Created by Eduardo on 23/09/24.
//

import SwiftData

@Model
class KeymapModel {
    // Dictionary to store key mappings
    var keyMap: [UInt16: GameActions]
    
    // Initializer for KeymapModel
    init(keyMap: [UInt16: GameActions]) {
        self.keyMap = keyMap
    }
    
    // Method to get the current key map
    func getKeyMap() -> [UInt16: GameActions] {
        return keyMap
    }
    
    // Method to update the key map
    func setKeyMap(_ newKeyMap: [UInt16: GameActions]) {
        self.keyMap = newKeyMap
    }
}

