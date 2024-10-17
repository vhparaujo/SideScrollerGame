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
import GameController

@MainActor
class GameControllerManager {
    
    public static var shared = GameControllerManager()
    
    var keyPressPublisher = PassthroughSubject<GameActions, Never>()
    var keyReleasePublisher = PassthroughSubject<GameActions, Never>()
    
    var keymapModel: KeymapModel
    
    private init() {
        
        // Default key mapping using GCKeyCode
        let keyMapDefault: [GCKeyCode: GameActions] = [
            .keyW: .climb,     // W key
            .keyA: .moveLeft,  // A key
            .keyD: .moveRight, // D key
            .spacebar: .jump,  // Space key
            .keyE: .action,     // E key
            .leftShift: .brintToPresent, // Left Shift key
                .keyS: .down,
        ]
        
        if let keymap = SwiftDataManager.shared.fetchFirstKeymap() {
            keymapModel = keymap
        } else {
            keymapModel = KeymapModel(keyMap: keyMapDefault)
            SwiftDataManager.shared.insertKeymap(keymapModel)
        }
        
        // Observe for keyboard connections
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidConnect), name: .GCKeyboardDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidDisconnect), name: .GCKeyboardDidDisconnect, object: nil)
        
        // If keyboard is already connected
        if let keyboardInput = GCKeyboard.coalesced?.keyboardInput {
            setupKeyboardInput(keyboardInput)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardDidConnect(notification: Notification) {
        if let keyboard = notification.object as? GCKeyboard {
            if let keyboardInput = keyboard.keyboardInput {
                setupKeyboardInput(keyboardInput)
            }
        }
    }
    
    @objc func keyboardDidDisconnect(notification: Notification) {
        // Handle keyboard disconnection if necessary
    }
    
    func setupKeyboardInput(_ keyboardInput: GCKeyboardInput) {
        keyboardInput.keyChangedHandler = { [weak self] keyboard, key, keyCode, pressed in
            guard let self = self else { return }
            let keyMap = self.keymapModel.getKeyMap()
            if let action = keyMap[keyCode] {
                if pressed {
                    self.keyPressPublisher.send(action)
                } else {
                    self.keyReleasePublisher.send(action)
                }
            }
        }
    }
    
    // Function to change the key mapping
    func changeKey(forAction action: GameActions, toKeyCode newKeyCode: GCKeyCode) {
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
        let keyMapDefault: [GCKeyCode: GameActions] = [
            .keyW: .climb,     // W key
            .keyA: .moveLeft,  // A key
            .keyD: .moveRight, // D key
            .spacebar: .jump,  // Space key
            .keyE: .action     // E key
        ]
        
        // Reset the keymap model to default and save it
        SwiftDataManager.shared.updateKeymap(keymapModel) { updatedKeymap in
            updatedKeymap.setKeyMap(keyMapDefault)
        }
    }
    
    func getKeymap() -> [GCKeyCode: GameActions] {
        return keymapModel.getKeyMap()
    }
}

