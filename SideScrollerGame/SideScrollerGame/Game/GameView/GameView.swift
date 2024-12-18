//
//  GameScene.swift
//  SideScrollerGame
//
//  Created by Eduardo on 18/09/24.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @StateObject var viewModel: GameViewModel = .shared
    var currentSceneType: SceneType? {
        didSet {
            self.viewModel.currentSceneType = currentSceneType!
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                SpriteView(scene: viewModel.createScene(size: CGSize(width: 1920, height: 1080)))
                    .ignoresSafeArea()
                    .id(viewModel.currentSceneType) 
                    .opacity(viewModel.opacity)
                    .background(.black)
            }
        }
    }
    
    
}

enum SceneType: Hashable {
    case first(PlayerEra)
    case second(PlayerEra)
    case third(PlayerEra)
}
