//
//  GameScene.swift
//  SideScrollerGame
//
//  Created by Eduardo on 18/09/24.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @State var currentSceneType: SceneType
    @State private var opacity: Double = 1.0
    
    @Bindable var mpManager: MultiplayerManager
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                SpriteView(scene: createScene(size: CGSize(width: 1920, height: 1080)), debugOptions: [.showsFPS, .showsNodeCount, .showsPhysics])
                    .ignoresSafeArea()
                    .id(currentSceneType) // Force refresh when the scene type changes
                    .opacity(opacity)      // Use opacity to control fade in/out
                    .animation(.easeInOut(duration: 1.0), value: opacity) // Add animation to opacity
            }
        }
    }
    
    func createScene(size: CGSize) -> SKScene {
        switch currentSceneType {
            case .first(let playerEra):
                return FirstScene(size: size, mpManager: mpManager, playerEra: playerEra)
        }
    }
    
    func transitionScene(to newScene: SceneType) {
            withAnimation {
                self.currentSceneType = newScene
            }
        }
}

enum SceneType: Hashable {
    case first(PlayerEra)
}
