//
//  GameActions.swift
//  SideScrollerGame
//
//  Created by Eduardo on 19/09/24.
//

import GameController

enum GameActions: String, Codable {
    case moveLeft
    case moveRight
    case jump
    case climb
    case action
    
    var allCases: [GameActions] {
        [.moveLeft, .moveRight/*, .jump*/, .climb, .action]
    }
}

extension GCKeyCode: Codable {
    
}
