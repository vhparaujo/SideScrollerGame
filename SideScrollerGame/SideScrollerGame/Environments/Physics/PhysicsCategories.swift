//
//  PhysicsCategories.swift
//  SideScrollerGame
//
//  Created by Eduardo on 18/09/24.
//

import Foundation

struct PhysicsCategories {
    static let none: UInt32 = 0
    static let player: UInt32 = 0x1 << 0
    static let ground: UInt32 = 0x1 << 1
    static let box: UInt32   = 0x1 << 2
    static let platform: UInt32 = 0x1 << 3
    static let fatal: UInt32   = 0x1 << 4
}
