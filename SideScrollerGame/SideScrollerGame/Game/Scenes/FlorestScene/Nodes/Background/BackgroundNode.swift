//
//  BackgroundNode.swift
//  SideScrollerGame
//
//  Created by Eduardo on 19/09/24.
//

// BackgroundNode.swift

import SpriteKit

class BackgroundNode: SKSpriteNode {
    
    init(_ textureName: String) {
        let texture = SKTexture(imageNamed: textureName)
        super.init(texture: texture, color: .clear, size: texture.size())
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
