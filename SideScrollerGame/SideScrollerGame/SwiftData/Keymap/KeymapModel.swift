//
//  KeymapModel.swift
//  SideScrollerGame
//
//  Created by Eduardo on 19/09/24.
//

import SwiftData

// Model to store key mapping using SwiftData
@Model
class KeymapModel: Codable {
    
    // Store key codes and actions as arrays to serialize them
    var keyCodes: [UInt16]
    var actions: [String]
    
    init(keyMap: [UInt16: GameActions]) {
        // Convert the dictionary to two arrays: one for key codes, one for actions
        self.keyCodes = Array(keyMap.keys)
        self.actions = keyMap.values.map { $0.rawValue }
    }
    
    // Function to get keyMap from the stored key codes and actions
    func getKeyMap() -> [UInt16: GameActions] {
        var keyMap: [UInt16: GameActions] = [:]
        for (index, keyCode) in keyCodes.enumerated() {
            if let action = GameActions(rawValue: actions[index]) {
                keyMap[keyCode] = action
            }
        }
        return keyMap
    }
    
    // Function to update the stored keyMap
    func updateKeyMap(with keyMap: [UInt16: GameActions]) {
        self.keyCodes = Array(keyMap.keys)
        self.actions = keyMap.values.map { $0.rawValue }
    }
    
    // Encoding and decoding methods for conforming to Codable
    enum CodingKeys: String, CodingKey {
        case keyCodes, actions
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        keyCodes = try container.decode([UInt16].self, forKey: .keyCodes)
        actions = try container.decode([String].self, forKey: .actions)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(keyCodes, forKey: .keyCodes)
        try container.encode(actions, forKey: .actions)
    }
}
