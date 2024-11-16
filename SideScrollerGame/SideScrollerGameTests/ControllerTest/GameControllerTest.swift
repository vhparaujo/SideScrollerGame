//
//  GameControllerTest.swift
//  SideScrollerGame
//
//  Created by Eduardo on 23/09/24.
//

import Testing
@testable import SideScrollerGame

struct GameControllerTest {
    
    var gameController: GameControllerManager
    
    init() async {
        self.gameController = await GameControllerManager()
    }
    
    
//    @Test func getKeyMapTest() async throws {
//        
//        // Initialize the keymapModel with the default key map
//        var keymap: [UInt16: GameActions] {
//            return [
//                13: .climb,     // W key
//                0:  .moveLeft,  // A key
//                2:  .moveRight, // D key
//                49: .jump,      // Space key
//                14: .grab       // E key
//            ]
//        }
//        await #expect(gameController.getKeymap() == keymap)
//    }
    
    @Test func setKeyMapTest() async throws {
        
        // Initialize the keymapModel with the default key map
        var keymap: [UInt16: GameActions] {
            return [
                13: .climb,     // W key
                0:  .moveLeft,  // A key
                2:  .moveRight, // D key
                5: .jump,      // random key
                14: .action       // E key
            ]
        }
        
        await gameController.changeKey(forAction: .jump, toKeyCode: 5)
        
        await #expect(gameController.getKeymap() == keymap)
        
    }
    
    @Test func resetKeyMapTest() async throws {
        
        var keymap: [UInt16: GameActions] {
            return [
                13: .climb,     // W key
                0:  .moveLeft,  // A key
                2:  .moveRight, // D key
                49: .jump,      // Space key
                14: .action       // E key
            ]
        }
        
        await gameController.changeKey(forAction: .jump, toKeyCode: 5)
        
        await #expect(gameController.getKeymap() != keymap)

        await gameController.resetKeyMapping()
        
        await #expect(gameController.getKeymap() == keymap)
        
    }
}

