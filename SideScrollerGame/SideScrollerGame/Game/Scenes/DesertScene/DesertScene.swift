//
//  DesertScene.swift
//  SideScrollerGame
//
//  Created by Eduardo on 19/09/24.
//

import Foundation
import SpriteKit

class DesertScene: SKScene {
    var parallaxBackground: ParallaxBackground?
    
    override func didMove(to view: SKView) {
        self.name = "DesertScene"
        self.backgroundColor = .yellow
        // Set up your DesertScene here
        setupBackground()
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
    
    func setupBackground() {
        let images: [String] = ["close-trees", "mid-trees", "far-trees", "background"]
        self.parallaxBackground = ParallaxBackground(screenSize: self.size, backgroundImages: images)
        
        self.addChild(parallaxBackground!)
    }
}
