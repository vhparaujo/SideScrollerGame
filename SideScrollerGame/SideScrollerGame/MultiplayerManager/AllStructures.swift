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
    var textureState: PlayerTextureState
    var facingRight: Bool
    var action: Bool
    var isDying: Bool
    var position: CGPoint
    var readyToNextScene: Bool
}

struct GameStartInfo: Codable{
    var local: PlayerStartInfo
    var other: PlayerStartInfo
}

struct PlayerStartInfo: Codable{
    var eraSelection: PlayerEra?
    var isStartPressed: IsPressed
}

enum IsPressed: Codable{
    case yes
    case no
}

struct BoxTeletransport: Codable{
    var position: CGPoint
    var id: UUID
    var isGrabbed: Bool
}
