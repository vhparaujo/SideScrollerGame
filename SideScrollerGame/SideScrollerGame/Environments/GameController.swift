//
//  Controllers.swift
//  SideScrollerGame
//
//  Created by Eduardo on 19/09/24.
//

import Foundation
import AppKit

@Observable class GameController {
    
    private var keyMap: [UInt16: GameActions] = [:]  // Now using keyCode as the key, and action as the value
    
    init() {
        // Key mappings (Mac key codes for specific actions)
        keyMap[13] = .climb  // 'W' key
        keyMap[0]  = .moveLeft   // 'A' key
        keyMap[2]  = .moveRight  // 'D' key
        keyMap[49] = .jump   // Spacebar
        keyMap[14] = .grab   // 'E' key
        
        // Monitor for key press and release events
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { [weak self] event in
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        if let action = keyMap[event.keyCode] {
            if event.type == .keyDown {
                keyPressed(action)
            }
            if event.type == .keyUp {
                keyReleased(action)
            }
        }
    }
    
    private func keyPressed(_ action: GameActions) {
        // Implement your logic for when a valid key is pressed
        print("Key pressed for action: \(action)")
    }
    
    private func keyReleased(_ action: GameActions) {
        // Implement your logic for when a valid key is released
        print("Key released for action: \(action)")
    }
    
    // Function to change the key mapping
    func changeKey(forAction action: GameActions, toKeyCode newKeyCode: UInt16) {
        // Remove the current mapping for the given action, if it exists
        if let oldKeyCode = keyMap.first(where: { $0.value == action })?.key {
            keyMap.removeValue(forKey: oldKeyCode)
        }
        
        // Assign the new key code to the action
        keyMap[newKeyCode] = action
        
        print("Key mapping updated: \(action) is now mapped to keyCode \(newKeyCode)")
    }
}
