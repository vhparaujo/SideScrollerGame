//
//  ElevatorNode.swift
//  SideScrollerGame
//
//  Created by Gabriel Eduardo on 02/10/24.
//

import SpriteKit

enum ElevatorMode {
    case automatic
    case manual
}

class ElevatorNode: SKNode {
    let mode: ElevatorMode
    let elevatorBody = SKSpriteNode(texture: SKTexture(imageNamed: "ElevatorBody"), color: .blue, size: CGSize(width: 200, height: 400))
    let elevatorPlatform = SKSpriteNode(texture: SKTexture(imageNamed: "ElevatorPlatform"), color: .red, size: CGSize(width: 200, height: 50))
    
    init(mode: ElevatorMode) {
        self.mode = mode
        super.init()
        
        
        self.elevatorBody.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        self.elevatorPlatform.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        
        
        self.addChild(elevatorBody)
        elevatorBody.addChild(elevatorPlatform)
        
        self.elevatorPlatform.position = CGPoint(x: 0, y: 400)
        
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setPhysicsBody()
    }
    
    private func setPhysicsBody() {
        elevatorPlatform.physicsBody = SKPhysicsBody(rectangleOf: elevatorPlatform.size)
        elevatorPlatform.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        elevatorPlatform.physicsBody?.affectedByGravity = false
        elevatorPlatform.physicsBody?.isDynamic = false
        elevatorPlatform.physicsBody?.categoryBitMask = PhysicsCategories.ground
        elevatorPlatform.physicsBody?.collisionBitMask = PhysicsCategories.player
        elevatorPlatform.physicsBody?.contactTestBitMask = PhysicsCategories.player
    }
}

