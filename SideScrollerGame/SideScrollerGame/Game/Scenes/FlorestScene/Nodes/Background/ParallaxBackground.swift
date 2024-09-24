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
    let antiFlickering:CGFloat = 0.05
    var backgroundSize: CGSize
    var backgrounds: Array<SKSpriteNode>
    var clonedBackgrounds: Array<SKSpriteNode>
    var numberOfBackgrounds: Int
    let scrollingDirection: ScrollingDirection
    var speeds:[CGFloat]
    
    enum ScrollingDirection {
        case left
        case right
    }
    
    init(backgroundImages: Array<String>, backgroundSize: CGSize) {
        self.backgroundSize = backgroundSize
        self.backgrounds = []
        self.clonedBackgrounds = []
        self.numberOfBackgrounds = backgroundImages.count
        self.scrollingDirection = .left
        self.speeds = []
        
        super.init()
        
        
        let zPos = 1.0 / CGFloat(numberOfBackgrounds)
        
        self.zPosition = -100
    
        for (index, image) in backgroundImages.enumerated() {
            let background = BackgroundNode(image)

            background.zPosition = self.zPosition - (zPos + (zPos * CGFloat(index)))
            background.position = CGPointMake(0, 0)
            
            let clonedBackground = BackgroundNode(image)
            var clonedBackgroundX = background.position.x
            var clonedBackgroundY = background.position.y
            
            switch (scrollingDirection) {
            case .right:
                clonedBackgroundX = -background.size.width
            case .left:
                clonedBackgroundX = background.size.width
            default:
                break
            }

            var currentSpeed = CGFloat(2.0)
            
            clonedBackground.position = CGPointMake(clonedBackgroundX, clonedBackgroundY);
            backgrounds.append(background)
            clonedBackgrounds.append(clonedBackground)
            speeds.append(currentSpeed)
            
            self.addChild(background)
            self.addChild(clonedBackground)
        }
    }
    
    func moveBackGround() {
        for i in 0..<numberOfBackgrounds {
            var speed = self.speeds[i]

            var background = self.backgrounds[i]
            var clonedBackground = self.clonedBackgrounds[i]
        
            var adjustedBackgroundX = background.position.x
            var adjustedBackgroundY = background.position.y
            var adjustedClonedBackgroundX = clonedBackground.position.x
            var adjustedClonedBackgroundY = clonedBackground.position.y
            
            switch (self.scrollingDirection) {
            case .right:
                adjustedBackgroundX += speed
                adjustedClonedBackgroundX += speed
                if (adjustedBackgroundX >= background.size.width) {
                    adjustedBackgroundX = adjustedBackgroundX - 2 * background.size.width + antiFlickering
                }
                if (adjustedClonedBackgroundX >= clonedBackground.size.width) {
                    adjustedClonedBackgroundX = adjustedClonedBackgroundX - 2 * clonedBackground.size.width + antiFlickering
                }
            case .left:
                adjustedBackgroundX -= speed
                adjustedClonedBackgroundX -= speed

                if (adjustedBackgroundX <= -self.backgroundSize.width) {
                    adjustedBackgroundX = adjustedBackgroundX + 2 * self.backgroundSize.width - antiFlickering
                }
                if (adjustedClonedBackgroundX <= -self.scene!.size.width) {
                    adjustedClonedBackgroundX = adjustedClonedBackgroundX + 2 * self.backgroundSize.width - antiFlickering
                }
            default:
                break
            }
    
            // update positions with the right coordinates.
            background.position = CGPointMake(adjustedBackgroundX, adjustedBackgroundY)
            clonedBackground.position = CGPointMake(adjustedClonedBackgroundX, adjustedClonedBackgroundY)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
