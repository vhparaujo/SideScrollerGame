//
//  ShiftNode.swift
//  SideScrollerGame
//
//  Created by Eduardo on 08/11/24.
//

import SpriteKit

// Define a class that inherits from SKSpriteNode
class ImageSpriteNode: SKSpriteNode {
    
    // Initializer to create the sprite node with an image
    init(imageName: String = "shift", position: CGPoint) {
        // Create a texture from the image
        let texture = SKTexture(imageNamed: imageName)
        
        
        // Initialize the SKSpriteNode with the texture
        super.init(texture: texture, color: .clear, size: texture.size())
        self.setScale(3)
        // Set the position of the sprite
        self.position = position
    }
    
    // Required initializer (for SKSpriteNode subclass)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

