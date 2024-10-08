//
//  PlatformNode.swift
//  SideScrollerGame
//
//  Created by Eduardo on 26/09/24.
//

import SpriteKit

class PlatformNode: SKSpriteNode {
    var moveSpeed: CGFloat = 100.0 // Adjust speed as needed
    var movingRight: Bool = true
    var minX: CGFloat
    var maxX: CGFloat

    private var previousPosition: CGPoint = .zero // Store previous position

    init(minX: CGFloat, maxX: CGFloat) {
        self.minX = minX
        self.maxX = maxX

        let texture = SKTexture(imageNamed: "platform") // Replace with your platform image
        super.init(texture: texture, color: .clear, size: texture.size())
        self.zPosition = 0 // Adjust as needed

        // Set up physics body
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false // Keep platform static
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategories.platform
        self.physicsBody?.contactTestBitMask = PhysicsCategories.player
        self.physicsBody?.collisionBitMask = PhysicsCategories.player
        self.physicsBody?.friction = 0.0 // High friction to move the player
        self.physicsBody?.restitution = 0.0

        self.previousPosition = self.position // Initialize previous position
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(deltaTime: TimeInterval) {
        // Calculate the distance the platform will move
        let distance = moveSpeed * CGFloat(deltaTime)
        // Store the previous position
        previousPosition = self.position

        // Move the platform
        if movingRight {
            self.position.x += distance
            if self.position.x >= maxX {
                self.position.x = maxX
                movingRight = false
            }
        } else {
            self.position.x -= distance
            if self.position.x <= minX {
                self.position.x = minX
                movingRight = true
            }
        }
    }

    // Function to get movement delta
    func movementDelta() -> CGPoint {
        return CGPoint(x: self.position.x - previousPosition.x, y: self.position.y - previousPosition.y)
    }
}

