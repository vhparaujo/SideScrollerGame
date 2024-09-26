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
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    
    let backgroundImages: [String]
    var background: [[SKSpriteNode]]
    let parallaxFactors: [CGFloat] = [0.2, 0.4, 0.6, 0.8] // Furthest to closest
    
    
    init(screenSize: CGSize, background: [String]) {
        self.screenWidth = screenSize.width
        self.screenHeight = screenSize.height
        
        self.backgroundImages = background
        self.background = Array(repeating: [SKSpriteNode](), count: backgroundImages.count)
        
        super.init()
        
        setupParallaxBackground()
    }
    
    func setupParallaxBackground() {
        for (backgroundIndex, backgroundImageName) in backgroundImages.enumerated() {
            for i in -1...1 {
                let bg = BackgroundNode(backgroundImageName, screenSize: CGSize(width: screenWidth, height: screenHeight))
                bg.position = CGPoint(x: CGFloat(i) * screenWidth, y: screenHeight / 2)
                bg.zPosition = CGFloat(-backgroundIndex)
                self.addChild(bg)
                self.background[backgroundIndex].append(bg)
            }
        }
    }
    
    func moveParallaxBackground(cameraMovementX: CGFloat) {
        // For each layer
        for (backgroundIndex, backgroundLayer) in background.enumerated() {
            // For each page
            for bgPage in backgroundLayer {
                bgPage.position.x += cameraMovementX * parallaxFactors[backgroundIndex]
            }
        }
    }
    
    func paginateBackgroundLayers(cameraNode: SKCameraNode) {
        // For each layer
        for backgroundLayer in background {
            for bgPage in backgroundLayer {
                let bgWidth = bgPage.size.width

                // Reposition horizontally
                if bgPage.position.x + bgWidth / 2 < cameraNode.position.x - screenWidth / 2 {
                    bgPage.position.x += bgWidth * CGFloat(backgroundLayer.count)
                } else if bgPage.position.x - bgWidth / 2 > cameraNode.position.x + screenWidth / 2 {
                    bgPage.position.x -= bgWidth * CGFloat(backgroundLayer.count)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
