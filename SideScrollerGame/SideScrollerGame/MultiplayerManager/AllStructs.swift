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

struct GameData: Codable {
    var matchName: String
    var playerName: String
    var score: Int?
    var message: String?
    var outcome: String?
}
