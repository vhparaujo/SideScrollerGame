//
//  AllStructs.swift
//  CubeEatForIos
//
//  Created by Jairo Júnior on 24/09/24.
//

import Foundation
import GameKit

struct Friend: Identifiable {
    var id = UUID()
    var player: GKPlayer
}

/// A message that one player sends to another.
struct Message: Identifiable {
    var id = UUID()
    var content: String
    var playerName: String
    var isLocalPlayer = false
}

// MARK: Game Data Objects
struct PlayerInfo: Codable{
    var position: CGPoint
    
    var isMovingLeft = false
    var isMovingRight = false
    var isGrounded = true
    var groundContactCount = 0 // Tracks number of ground contacts
    
    var facingRight = true // Tracks the orientation
}
