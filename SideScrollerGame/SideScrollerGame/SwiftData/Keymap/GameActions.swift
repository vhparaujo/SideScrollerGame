//
//  GameActions.swift
//  SideScrollerGame
//
//  Created by Eduardo on 19/09/24.
//

import GameController

enum GameActions: String, Codable, CaseIterable {
    case moveLeft
    case moveRight
    case jump
    case climb
    case action
    case bringToPresent
    case down
    
   
}

extension GCKeyCode: Codable {
    
}
