//
//  BackgroundTexture.swift
//  SideScrollerGame
//
//  Created by Gabriel Eduardo on 26/09/24.
//
import SpriteKit

enum BackgroundTexture {
    case desertScene
    
    func textures(for era: PlayerEra) -> [String] {
        switch (self, era) {
        case (.desertScene, .present):
            return ["background-scene1-present-1", "background-scene1-present-2", "background-scene1-present-3", "background-scene1-present-4"]
        case (.desertScene, .future):
            return ["background-scene1-future-1", "background-scene1-future-2", "background-scene1-future-3", "background-scene1-future-4"]
        }
    }
}
