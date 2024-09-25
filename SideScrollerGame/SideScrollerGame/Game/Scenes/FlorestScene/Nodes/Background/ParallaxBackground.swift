//
//  ParallaxBackground.swift
//  SideScrollerGame
//
//  Created by Eduardo on 19/09/24.
//

// ParallaxBackground.swift

import SwiftUI
import SpriteKit

class ParallaxBackground: SKNode {
    var background: [[SKSpriteNode]] = [[], [], [], []]
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    
    init(screenSize: CGSize) {
        self.screenWidth = screenSize.width
        self.screenHeight = screenSize.height
        
        super.init()
    }
    
    func setupParallaxBackground() {
        for i in -1...1 {
            let bg = SKSpriteNode(imageNamed: "background")
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bg.position = CGPoint(x: CGFloat(i) * screenWidth, y: screenHeight / 2)
            bg.zPosition = -4
            bg.size = CGSize(width: screenWidth, height: screenHeight)
            addChild(bg)
            background[0].append(bg)
        }

        // Far Trees Layer
        for i in -1...1 {
            let farTrees = SKSpriteNode(imageNamed: "far-trees")
            farTrees.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            farTrees.position = CGPoint(x: CGFloat(i) * screenWidth, y: screenHeight / 2)
            farTrees.zPosition = -3
            farTrees.size = CGSize(width: screenWidth, height: screenHeight)
            addChild(farTrees)
            background[1].append(farTrees)
        }

        // Mid Trees Layer
        for i in -1...1 {
            let midTrees = SKSpriteNode(imageNamed: "mid-trees")
            midTrees.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            midTrees.position = CGPoint(x: CGFloat(i) * screenWidth, y: screenHeight / 2)
            midTrees.zPosition = -2
            midTrees.size = CGSize(width: screenWidth, height: screenHeight)
            addChild(midTrees)
            background[2].append(midTrees)
        }

        // Close Trees Layer
        for i in -1...1 {
            let closeTrees = SKSpriteNode(imageNamed: "close-trees")
            closeTrees.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            closeTrees.position = CGPoint(x: CGFloat(i) * screenWidth, y: screenHeight / 2)
            closeTrees.zPosition = -1
            closeTrees.size = CGSize(width: screenWidth, height: screenHeight)
            addChild(closeTrees)
            background[3].append(closeTrees)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
