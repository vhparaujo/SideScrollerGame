//
//  ButtonsNode.swift
//  SideScrollerGame
//
//  Created by Gabriel Eduardo on 28/10/24.
//

import SpriteKit

class ButtonsNode: SKNode {
    let playerEra: PlayerEra
    var buttonOnePressed: Bool = false
    var buttonTwoPressed: Bool = false
    var buttonThreePressed: Bool = false
    
    lazy var buttonOne: SKSpriteNode = {
        let buttonOneTexture = SKTexture(imageNamed: "\(playerEra == .present ? "button-one-present" : "button-one-future")-1")
        return SKSpriteNode(texture: buttonOneTexture, color: .red, size: CGSize(width: 200, height: 200))
    }()
    
    lazy var buttonTwo: SKSpriteNode = {
        let buttonTwoTexture = SKTexture(imageNamed: "\(playerEra == .present ? "button-two-present" : "button-two-future")-1")
        return SKSpriteNode(texture: buttonTwoTexture, color: .red, size: CGSize(width: 200, height: 200))
    }()
    
    lazy var buttonThree: SKSpriteNode = {
        let buttonThreeTexture = SKTexture(imageNamed: "\(playerEra == .present ? "button-three-present" : "button-three-future")-1")
        return SKSpriteNode(texture: buttonThreeTexture, color: .red, size: CGSize(width: 200, height: 200))
    }()
    
    init(playerEra: PlayerEra) {
        self.playerEra = playerEra
        
        super.init()
        
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setPosition()
        setPhysicsBody()
    }
    
    private func setPhysicsBody() {
        buttonOne.physicsBody = SKPhysicsBody(rectangleOf: buttonOne.size)
        
        buttonOne.physicsBody?.affectedByGravity = false
        buttonOne.physicsBody?.isDynamic = false
        buttonOne.physicsBody?.friction = 0
        
        buttonOne.physicsBody?.categoryBitMask = PhysicsCategories.buttonDoor
        buttonOne.physicsBody?.collisionBitMask = 0
        buttonOne.physicsBody?.contactTestBitMask = PhysicsCategories.player
        
        buttonTwo.physicsBody = SKPhysicsBody(rectangleOf: buttonOne.size)
        
        buttonTwo.physicsBody?.affectedByGravity = false
        buttonTwo.physicsBody?.isDynamic = false
        buttonTwo.physicsBody?.friction = 0
        
        buttonTwo.physicsBody?.categoryBitMask = PhysicsCategories.buttonDoor
        buttonTwo.physicsBody?.collisionBitMask = 0
        buttonTwo.physicsBody?.contactTestBitMask = PhysicsCategories.player
        
        buttonThree.physicsBody = SKPhysicsBody(rectangleOf: buttonOne.size)
        
        buttonThree.physicsBody?.affectedByGravity = false
        buttonThree.physicsBody?.isDynamic = false
        buttonThree.physicsBody?.friction = 0
        
        buttonThree.physicsBody?.categoryBitMask = PhysicsCategories.buttonDoor
        buttonThree.physicsBody?.collisionBitMask = 0
        buttonThree.physicsBody?.contactTestBitMask = PhysicsCategories.player
    }
    
    private func setPosition() {
        self.buttonOne.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.buttonTwo.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.buttonThree.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.buttonOne.position = CGPoint(x: 0, y: 0)
        self.buttonTwo.position = CGPoint(x: 250, y: 0)
        self.buttonThree.position = CGPoint(x: 500, y: 0)
    }
}
