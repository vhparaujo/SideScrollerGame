//
//  ButtonsNode.swift
//  SideScrollerGame
//
//  Created by Gabriel Eduardo on 28/10/24.
//

import SpriteKit

class ButtonNode: SKSpriteNode {
    let playerEra: PlayerEra
    let spriteNode: SKSpriteNode
    
    var buttonPressed: Bool = false {
        didSet {
            if buttonPressed {
                self.spriteNode.run(SKAction.move(by: CGVector(dx: 0, dy: Int(-self.spriteNode.size.height)), duration: 1))
            } else {
                self.spriteNode.run(SKAction.move(by: CGVector(dx: 0, dy: Int(self.spriteNode.size.height)), duration: 1))
            }
        }
    }
    
    init(playerEra: PlayerEra, buttonName: String) {
        self.playerEra = playerEra
        
        let buttonTexture = SKTexture(imageNamed: "\(playerEra == .present ? "\(buttonName)-present" : "\(buttonName)-future")-1")
        self.spriteNode = SKSpriteNode(texture: buttonTexture, color: .red, size: CGSize(width: 200, height: 200))
        self.spriteNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        super.init(texture: buttonTexture, color: .clear, size: buttonTexture.size())
    
        self.name = buttonName
        
        setPhysicsBody(node: self, size: self.spriteNode.size)
        
        self.addChild(self.spriteNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setPhysicsBody(node: SKNode, size: CGSize) {
        node.physicsBody = SKPhysicsBody(rectangleOf: size)
        
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.isDynamic = false
        node.physicsBody?.friction = 0
        
        node.physicsBody?.categoryBitMask = PhysicsCategories.buttonDoor
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.contactTestBitMask = PhysicsCategories.player
    }
}

class ButtonsNode: SKNode {
    let playerEra: PlayerEra
    
    lazy var buttonOne: SKNode = {
        let button = ButtonNode(playerEra: self.playerEra, buttonName: "button-one")
        return button
    }()
    
    lazy var buttonTwo: SKNode = {
        let button = ButtonNode(playerEra: self.playerEra, buttonName: "button-two")
        return button
    }()
    
    lazy var buttonThree: SKNode = {
        let button = ButtonNode(playerEra: self.playerEra, buttonName: "button-three")
        return button
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
        
        self.name = "ButtonsNode"
        
        self.addChild(buttonOne)
        self.addChild(buttonTwo)
        self.addChild(buttonThree)
    }
    
    private func setPosition() {
        self.buttonOne.position = CGPoint(x: 0, y: 0)
        self.buttonTwo.position = CGPoint(x: 250, y: 0)
        self.buttonThree.position = CGPoint(x: 500, y: 0)
    }
}
