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
@Observable class GameController: ControllerProtocol {
    
    private var keyPressPublisher = PassthroughSubject<GameActions, Never>()
    private var keyReleasePublisher = PassthroughSubject<GameActions, Never>()
    
    //swiftData manager
    private var dataManager: SwiftDataManager = SwiftDataManager(conteiner: .appContainer)
    
    // Use SwiftData model for the key map
    private var keymapModel: KeymapModel
    
    init() {
        // Initialize the keymapModel with the default key map
        var keymap: [UInt16: GameActions] {
            return [
                13: .climb,     // W key
                0:  .moveLeft,  // A key
                2:  .moveRight, // D key
                49: .jump,      // Space key
                14: .grab       // E key
            ]
        }
        self.keymapModel = KeymapModel(keyMap: keymap)
        
        if let savedKeymap = fetchSavedKeymap() {
            print("use the saved key map")
            self.keymapModel = savedKeymap
        } else {
            print("Save the default key map")
            saveKeymapModel()
        }
        
        // Monitor for key press and release events
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { [weak self] event in
            self?.handleKeyEvent(event)
            return nil
        }
    }
    
    // Fetch saved KeymapModel from SwiftData
    private func fetchSavedKeymap() -> KeymapModel? {
        let fetchDescriptor: FetchDescriptor = dataManager.createFetchDescriptor(predicate: nil) as FetchDescriptor<KeymapModel>
        let results: [KeymapModel] = dataManager.fetch(fetchDescriptor)
        
        return results.first // Return the first saved key map if any exist
    }
    
    // Save the current KeymapModel to SwiftData
    private func saveKeymapModel() {
        dataManager.save()
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        let keyMap = keymapModel.getKeyMap() // Fetch current key map
        
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
        var keyMap = keymapModel.getKeyMap() // Fetch the current key map
        
        // Remove the current mapping for the given action, if it exists
        if let oldKeyCode = keyMap.first(where: { $0.value == action })?.key {
            keyMap.removeValue(forKey: oldKeyCode)
        }
        
        // Assign the new key code to the action
        keyMap[newKeyCode] = action
        
        // Update the SwiftData model with the new key map
        keymapModel.updateKeyMap(with: keyMap)
        
        print("Key mapping updated: \(action) is now mapped to keyCode \(newKeyCode)")
    }
    
    func resetKeyMapping() {
        var keymap: [UInt16: GameActions] {
            return [
                13: .climb,     // W key
                0:  .moveLeft,  // A key
                2:  .moveRight, // D key
                49: .jump,      // Space key
                14: .grab       // E key
            ]
        }
        
        keymapModel.updateKeyMap(with: keymap)
    }
}
