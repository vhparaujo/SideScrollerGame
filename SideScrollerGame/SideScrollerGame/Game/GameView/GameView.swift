//
//  GameScene.swift
//  SideScrollerGame
//
//  Created by Eduardo on 18/09/24.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @State private var currentSceneType: SceneType = .desert
    @State private var opacity: Double = 1.0
    
    @Bindable var mpManager: MultiplayerManager
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                
                SpriteView(scene: createScene(size: geometry.size), debugOptions: [.showsFPS, .showsNodeCount, .showsPhysics])
                    .ignoresSafeArea()
                    .id(currentSceneType) // Force refresh when the scene type changes
                    .opacity(opacity)      // Use opacity to control fade in/out
                    .animation(.easeInOut(duration: 1.0), value: opacity) // Add animation to opacity
                
            }
        }
    }
    
    func createScene(size: CGSize) -> SKScene {
        switch currentSceneType {
        case .desert:
            return DesertScene(size: size, mpManager: mpManager)
        }
    }
    
    func transitionScene(to newScene: SceneType) {
        // Start by fading out the current scene
        withAnimation {
            opacity = 0.0
        }
        
        // After the fade-out completes (1 second), switch the scene and fade back in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            currentSceneType = newScene
            withAnimation {
                opacity = 1.0
            }
        }
    }
    
    enum SceneType: Hashable {
        case desert
    }
}



#Preview {
    GameView(mpManager: .init())
}
