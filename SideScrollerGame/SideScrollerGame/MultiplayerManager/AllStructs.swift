//
//  AllStructs.swift
//  CubeEatForIos
//
//  Created by Jairo Júnior on 24/09/24.
//

import Foundation
import GameKit

// MARK: Game Data Objects
struct PlayerInfo: Codable{
    var isMovingRight: Bool
    var isMovingLeft: Bool
    var state: PlayerTextureState
    var facingRight: Bool
    var isGrabbed: Bool
    var isGrounded: Bool
}
