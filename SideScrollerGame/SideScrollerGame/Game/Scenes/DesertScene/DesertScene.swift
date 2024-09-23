//
//  DesertScene.swift
//  SideScrollerGame
//
//  Created by Eduardo on 19/09/24.
//

import Foundation
import SpriteKit

class DesertScene: SKScene {
    
    override func didMove(to view: SKView) {
        self.name = "DesertScene"
        self.backgroundColor = .yellow
        // Set up your DesertScene here
        setupBackground()
    }
    
    func setupBackground() {
        let images: [String] = ["close-trees", "mid-trees", "far-trees", "background"]
        let parallaxBackground = ParallaxBackground(backgroundImages: images, scrollingDirection: .Right)
        
        parallaxBackground.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        
        self.addChild(parallaxBackground)
    }
}
