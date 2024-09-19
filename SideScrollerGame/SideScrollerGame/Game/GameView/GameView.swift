//
//  GameScene.swift
//  SideScrollerGame
//
//  Created by Eduardo on 18/09/24.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @State private var currentSceneType: SceneType = .florest
    @State private var opacity: Double = 1.0

    var body: some View {
        GeometryReader { geometry in
            VStack {
                SpriteView(scene: createScene(size: geometry.size))
                    .ignoresSafeArea()
                    .id(currentSceneType) // Force refresh when the scene type changes
                    .opacity(opacity)      // Use opacity to control fade in/out
                    .animation(.easeInOut(duration: 1.0), value: opacity) // Add animation to opacity
                HStack {
                    Button("Florest Scene") {
                        transitionScene(to: .florest)
                    }
                    .padding()
                    Button("Desert Scene") {
                        transitionScene(to: .desert)
                    }
                    .padding()
                }
            }
        }
    }

    func createScene(size: CGSize) -> SKScene {
        switch currentSceneType {
        case .florest:
            return FlorestScene(size: size)
        case .desert:
            return DesertScene(size: size)
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
        case florest
        case desert
    }
}



#Preview {
    GameView()
}
