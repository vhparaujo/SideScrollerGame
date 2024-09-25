//
//  BoxNode.swift
//  SideScrollerGame
//
//  Created by Eduardo on 25/09/24.
//

import SpriteKit

class BoxNode: SKSpriteNode {
    var isGrabbed: Bool = false

    init() {
        let texture = SKTexture(imageNamed: "box") // Replace with your box texture
        super.init(texture: texture, color: .clear, size: texture.size())
        self.name = "Box"
        self.zPosition = 1
        setupPhysicsBody()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategories.box
        self.physicsBody?.contactTestBitMask = PhysicsCategories.player | PhysicsCategories.ground
        self.physicsBody?.collisionBitMask = PhysicsCategories.ground | PhysicsCategories.box | PhysicsCategories.player
        self.physicsBody?.friction = 0.0
        self.physicsBody?.restitution = 0.0
    }
}

