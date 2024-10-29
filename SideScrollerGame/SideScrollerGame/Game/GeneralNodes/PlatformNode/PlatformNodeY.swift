//
//  PlatformNodeY.swift
//  SideScrollerGame
//
//  Created by Eduardo on 26/09/24.
//

import SpriteKit

class PlatformNodeY: SKSpriteNode, PlatformNodeProtocol {
    var moveSpeed: CGFloat = 100 // Adjust speed as needed
    var movingUp: Bool = true
    var minY: CGFloat
    var maxY: CGFloat

    private var previousPosition: CGPoint = .zero // Store previous position

    init(minY: CGFloat, maxY: CGFloat, position: CGPoint, moveSpeed: CGFloat) {
        self.minY = minY
        self.maxY = maxY
        
        self.moveSpeed = moveSpeed

        let texture = SKTexture(imageNamed: "platform") // Replace with your platform image
        super.init(texture: texture, color: .clear, size: texture.size())
        self.position = position
        
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
        if movingUp {
            self.position.y += distance
            
            if self.position.y >= maxY {
                self.position.y = maxY
                movingUp = false
            }
        } else {
            self.position.y -= distance
            if self.position.y <= minY {
                self.position.y = minY
                movingUp = true
            }
        }
    }

    // Function to get movement delta
    func movementDelta() -> CGPoint {
        return CGPoint(x: self.position.x - previousPosition.x, y: self.position.y - previousPosition.y)
    }
}

