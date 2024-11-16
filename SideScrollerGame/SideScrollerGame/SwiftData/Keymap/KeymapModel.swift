//
//  KeymapModel.swift
//  SideScrollerGame
//
//  Created by Eduardo on 23/09/24.
//

import SwiftData
import GameController

@Model
class KeymapModel {
    // Dictionary to store key mappings
    var keyMap: [GCKeyCode: GameActions]
    
    // Initializer for KeymapModel
    init(keyMap: [GCKeyCode: GameActions]) {
        self.keyMap = keyMap
    }
    
    // Method to get the current key map
    func getKeyMap() -> [GCKeyCode: GameActions] {
        return keyMap
    }
    
    // Method to update the key map
    func setKeyMap(_ newKeyMap: [GCKeyCode: GameActions]) {
        self.keyMap = newKeyMap
    }
}

