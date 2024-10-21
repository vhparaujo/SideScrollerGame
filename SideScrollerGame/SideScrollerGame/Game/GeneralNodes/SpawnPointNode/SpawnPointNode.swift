//
//  SpawnPointNode.swift
//  SideScrollerGame
//
//  Created by Eduardo on 07/10/24.
//

import SpriteKit

class SpawnPointNode: SKSpriteNode {
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
        self.physicsBody?.categoryBitMask = PhysicsCategories.spawnPoint
        self.physicsBody?.contactTestBitMask = PhysicsCategories.player
        self.physicsBody?.collisionBitMask = 0
    }
}
