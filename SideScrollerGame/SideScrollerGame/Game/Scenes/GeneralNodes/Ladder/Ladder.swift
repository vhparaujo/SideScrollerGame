//
//  Ladder.swift
//  SideScrollerGame
//
//  Created by Victor Hugo Pacheco Araujo on 16/10/24.
//

import SpriteKit

class Ladder: SKSpriteNode {
        
    init() {
        let texture = SKTexture(imageNamed: "Ladder") // Replace with your box texture
        super.init(texture: texture, color: .clear, size: CGSize(width: 80, height: 2000))
        self.name = "Ladder"
        self.zPosition = 1
        setupPhysicsBody()
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategories.ladder
    }
        
}
