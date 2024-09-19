//
//  GameModel.swift
//  SideScrollerGame
//
//  Created by Eduardo on 19/09/24.
//

// GameModel.swift

import Observation

@Observable
class GameModel {
    var player: PlayerNode
    var score: Int = 0
    var isGameOver: Bool = false
    // Add other game state properties as needed
    
    init(player: PlayerNode) {
        self.player = player
    }
}
