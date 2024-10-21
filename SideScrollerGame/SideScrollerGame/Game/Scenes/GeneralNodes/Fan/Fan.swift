//
//  Fan.swift
//  SideScrollerGame
//
//  Created by Victor Hugo Pacheco Araujo on 17/10/24.
//

import SpriteKit

class Fan: SKSpriteNode {
    
    init() {
        let texture = SKTexture(imageNamed: "fan") // Replace with your box texture
        super.init(texture: texture, color: .clear, size: CGSize(width: 200, height: 2000))
        self.name = "fan"
        self.zPosition = 1
        setupPhysicsBody()
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategories.fan
        self.physicsBody?.collisionBitMask = 0x0 // Evitar que o player colida
    }
    
}
