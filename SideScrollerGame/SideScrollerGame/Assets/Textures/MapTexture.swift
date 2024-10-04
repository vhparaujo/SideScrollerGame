//
//  MapTexture.swift
//  SideScrollerGame
//
//  Created by Eduardo on 03/10/24.
//

import SpriteKit

enum MapTexture {
    case firstScene
    
    
    func textures(for era: PlayerEra) -> String {
        switch (self, era) {
            case (.firstScene, .present):
                return "FirstPresentScene"
            case (.firstScene, .future):
                return "FirstFutureScene"
        }
    }
}
