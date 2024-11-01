//
//  Fan.swift
//  SideScrollerGame
//
//  Created by Victor Hugo Pacheco Araujo on 17/10/24.
//

import SpriteKit

class Fan: SKSpriteNode {
    
    init() {
        let texture = SKTexture(imageNamed: "fan-animation-action-lines-1") // Replace with your box texture
        super.init(texture: texture, color: .clear, size: CGSize(width: 150, height: 1000))
        self.name = "fan"
        self.zPosition = 1
        setupPhysicsBody()
        changeWindAnimation()
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.categoryBitMask = PhysicsCategories.fan
        self.physicsBody?.collisionBitMask = 0x0 | PhysicsCategories.fanBase // Evitar que o player colida
        self.physicsBody?.mass = CGFloat(Int.max)
    }
    
    func changeWindAnimation() {
        // Crie as texturas da animação
        let textures = [
            SKTexture(imageNamed: "fan-animation-action-lines-1"),
            SKTexture(imageNamed: "fan-animation-action-lines-2")
        ]
        
        // Crie a ação de animação com uma duração para cada frame
        let animationAction = SKAction.animate(with: textures, timePerFrame: 0.1)
        
        // Repita a animação indefinidamente
        let repeatAction = SKAction.repeatForever(animationAction)
        
        // Execute a ação de animação no nó
        self.run(repeatAction, withKey: "FanWindAnimation")
    }

}

class fanBase: SKSpriteNode {
    init() {
        let texture = SKTexture(imageNamed: "fan-future-on")
        super.init(texture: texture, color: .clear, size: CGSize(width: 200, height: 150))
        self.name = "fanBase"
        self.zPosition = 1
        setupPhysicsBody()
        addWind()
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategories.fanBase
        self.physicsBody?.collisionBitMask = PhysicsCategories.player | PhysicsCategories.ground | PhysicsCategories.fan
        self.physicsBody?.mass = CGFloat(Int.max)
    }
    
    func addWind() {
        let newFan = Fan()
        newFan.position.y = self.size.height + newFan.size.height / 2
        newFan.position.x = self.position.x
        self.addChild(newFan)
    }

}
