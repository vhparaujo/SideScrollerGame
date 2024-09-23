//
//  GameActions.swift
//  SideScrollerGame
//
//  Created by Eduardo on 19/09/24.
//

enum GameActions: String {
    case moveLeft
    case moveRight
    case jump
    case climb
    case grab
    
    var allCases: [GameActions] {
        [.moveLeft, .moveRight, .jump, .climb, .grab]
    }
}
