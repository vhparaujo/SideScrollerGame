//
//  PhysicsCategories.swift
//  SideScrollerGame
//
//  Created by Eduardo on 18/09/24.
//

import Foundation

struct PhysicsCategories {
    static let none: UInt32 = 100
    static let otherPlayer: UInt32 = 0x1 << 0
    static let player: UInt32 = 0x1 << 0
    static let ground: UInt32 = 0x1 << 1
    static let box: UInt32   = 0x1 << 2
    static let platform: UInt32 = 0x1 << 3
    static let moveButton: UInt32 = 0x1 << 4
    static let Death: UInt32  = 0x1 << 5
    static let wall: UInt32    = 0x1 << 6
    static let spawnPoint: UInt32 = 0x1 << 7  // Add this line
    static let ladder: UInt32 = 0x1 << 8
    static let fan: UInt32 = 0x1 << 9
    static let nextScene: UInt32 = 0x1 << 10
    static let buttonDoor: UInt32 = 0x1 << 11
}
