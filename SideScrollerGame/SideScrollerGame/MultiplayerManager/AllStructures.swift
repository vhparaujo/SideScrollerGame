//
//  AllStructs.swift
//  CubeEatForIos
//
//  Created by Jairo Júnior on 24/09/24.
//

import Foundation
import GameKit

// MARK: Game Data Objects
struct PlayerInfo: Codable {
    var isMovingRight: Bool
    var isMovingLeft: Bool
    var textureState: PlayerTextureState
    var facingRight: Bool
    var action: Bool
    var isGrounded: Bool
    var isJumping: Bool
    var alreadyJumping: Bool
    var isDying: Bool
    var position: CGPoint
}

struct GameStartInfo: Codable{
    var playerEraSelection: PlayerEra?
    var otherPlayerEraSelection: PlayerEra?
    var isStartPressedByPlayer: IsPressed
    var isStartPressedByOtherPlayer: IsPressed
}

enum IsPressed: UInt16, Codable{
    case yes = 1
    case no = 0
}
