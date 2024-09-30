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
    var position: CGPoint
    var velocity: CGVector
    var state: PlayerTextureState
    var facingRight: Bool
}
