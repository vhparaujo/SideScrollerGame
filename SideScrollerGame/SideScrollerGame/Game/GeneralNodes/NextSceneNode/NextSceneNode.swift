//
//  NextSceneNode.swift
//  SideScrollerGame
//
//  Created by Gabriel Eduardo on 18/10/24.
//

import SpriteKit

class NextSceneNode: SKSpriteNode {
    init(size: CGSize, position: CGPoint) {
        super.init(texture: nil, color: .green, size: size)
        self.position = position
        self.setupPhysicsBody()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupPhysicsBody()
    }

    func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategories.nextScene
        self.physicsBody?.contactTestBitMask = PhysicsCategories.player
        self.physicsBody?.collisionBitMask = 0
    }
}
