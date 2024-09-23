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
    var backgrounds: Array<SKSpriteNode>
    var clonedBackgrounds: Array<SKSpriteNode>
    let scrollingDirection:ScrollingDirection
    
    enum ScrollingDirection {
        case Left
        case Right
    }
    
    init(backgroundImages: Array<String>, scrollingDirection:ScrollingDirection) {
        self.backgrounds = []
        self.clonedBackgrounds = []
        self.scrollingDirection = scrollingDirection
        
        super.init()
        
        let numberOfBackgrounds = backgroundImages.count
        let zPos = 1.0 / CGFloat(numberOfBackgrounds)
        
        self.zPosition = -100
    
        for (index, image) in backgroundImages.enumerated() {
            let background = BackgroundNode(image)

            background.zPosition = self.zPosition - (zPos + (zPos * CGFloat(index)))
            background.position = CGPointMake(0, 0)

            backgrounds.append(background)
            
            self.addChild(background)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
