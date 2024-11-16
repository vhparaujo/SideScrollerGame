//
//  MapTexture.swift
//  SideScrollerGame
//
//  Created by Eduardo on 03/10/24.
//

import SpriteKit

enum MapTexture {
    case firstScene, secondScene, thirdScene
    
    func textures(for era: PlayerEra) -> String {
        switch (self, era) {
        case (.firstScene, .present):
            return "FirstPresentScene"
        case (.firstScene, .future):
            return "FirstFutureScene"
        case (.secondScene, .present):
            return "SecondPresentScene"
        case (.secondScene, .future):
            return "SecondFutureScene"
        case (.thirdScene, .present):
            return "ThirdPresentScene"
        case (.thirdScene, .future):
            return "ThirdFutureScene"
        }
    }
}
