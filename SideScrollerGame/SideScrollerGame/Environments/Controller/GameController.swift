//
//  Controllers.swift
//  SideScrollerGame
//
//  Created by Eduardo on 19/09/24.
//

import Foundation
import AppKit
import SwiftData
import Combine


// Updated GameController using KeymapModel from SwiftData
@MainActor
@Observable class GameController {
    
    var keyPressPublisher = PassthroughSubject<GameActions, Never>()
    var keyReleasePublisher = PassthroughSubject<GameActions, Never>()
    
    var keymapModel: KeymapModel
    
    init() {
        
        let keyMapDefault: [UInt16: GameActions] = {
            return [
                13: .climb,     // W key
                0:  .moveLeft,  // A key
                2:  .moveRight, // D key
                49: .jump,      // Space key
                14: .grab       // E key
            ]
        }()
        
        if let keymap = SwiftDataManager.shared.fetchFirstKeymap() {
            keymapModel = keymap
        }else {
            keymapModel = KeymapModel(keyMap: keyMapDefault)
            SwiftDataManager.shared.insertKeymap(keymapModel)
        }
        
        // Monitor for key press and release events
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { event in
            let keyMap = self.keymapModel.getKeyMap()
            if keyMap.keys.contains(event.keyCode) {
                self.handleKeyEvent(event)
                return event  // Suppress default behavior
            }
            return event  // Allow other events to be processed normally
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        let keyMap = keymapModel.getKeyMap()
        if let action = keyMap[event.keyCode] {
            if event.type == .keyDown {
                keyPressPublisher.send(action)
            } else if event.type == .keyUp {
                keyReleasePublisher.send(action)
            }
        }
    }
    
    // Function to change the key mapping
    func changeKey(forAction action: GameActions, toKeyCode newKeyCode: UInt16) {
        var currentKeyMap = keymapModel.getKeyMap()
        
        // Remove any existing mapping for the new key code
        if let oldAction = currentKeyMap[newKeyCode], oldAction != action {
            currentKeyMap[newKeyCode] = nil
        }
        
        // Find and remove the old key mapping for the action
        if let oldKeyCode = currentKeyMap.first(where: { $0.value == action })?.key {
            currentKeyMap.removeValue(forKey: oldKeyCode)
        }
        
        // Add the new key mapping
        currentKeyMap[newKeyCode] = action
        
        // Update the keymap model and save it
        SwiftDataManager.shared.updateKeymap(keymapModel) { updatedKeymap in
            updatedKeymap.setKeyMap(currentKeyMap)
        }
    }
    
    // Reset the key mappings to the default configuration
    func resetKeyMapping() {
        let keyMapDefault: [UInt16: GameActions] = {
            return [
                13: .climb,     // W key
                0:  .moveLeft,  // A key
                2:  .moveRight, // D key
                49: .jump,      // Space key
                14: .grab       // E key
            ]
        }()
        
        // Reset the keymap model to default and save it
        SwiftDataManager.shared.updateKeymap(keymapModel) { updatedKeymap in
            updatedKeymap.setKeyMap(keyMapDefault)
        }
        
    }
    
    func getKeymap() -> [UInt16: GameActions] {
        return keymapModel.getKeyMap()
    }
}
