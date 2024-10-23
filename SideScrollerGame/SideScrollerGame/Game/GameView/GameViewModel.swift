//
//  GameViewModel.swift
//  SideScrollerGame
//
//  Created by Gabriel Eduardo on 22/10/24.
//

import SwiftUI
import SpriteKit

class GameViewModel: ObservableObject {
    static var shared = GameViewModel()
    @Published var currentSceneType: SceneType
    @Published var opacity: Double = 1.0
    
    init(currentSceneType: SceneType = .first(.present)) {
        self.currentSceneType = currentSceneType
    }
    
    func createScene(size: CGSize) -> SKScene {
        switch currentSceneType {
            case .first(let playerEra):
            return FirstScene(size: size, mpManager: MultiplayerManager.shared, playerEra: playerEra)
        }
    }
    
    func transitionScene(to newScene: SceneType) {
        withAnimation {
            currentSceneType = newScene
            opacity = 0.0

            withAnimation(.default.delay(1.0)) {
                self.opacity = 1.0
            }
        }
    }
}