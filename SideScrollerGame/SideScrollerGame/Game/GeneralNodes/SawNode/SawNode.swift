//
//  SawNode.swift
//  SideScrollerGame
//
//  Created by Gabriel Eduardo on 11/10/24.
//

import SpriteKit

class SawNode: SKNode {
    let playerEra: PlayerEra
    var sawSpeed: CGFloat
    var range: CGFloat
    
    lazy var saw: SKSpriteNode = {
        let sawTexture = SKTexture(imageNamed: "\(playerEra == .present ? "present-saw-blade" : "future-saw-blade")-1")
        let saw = SKSpriteNode(texture: sawTexture, size: sawTexture.size())
        
        saw.physicsBody = SKPhysicsBody(circleOfRadius: saw.size.width / 2)
        
        saw.physicsBody?.affectedByGravity = false
        saw.physicsBody?.isDynamic = false
        saw.physicsBody?.friction = 0
        
        saw.physicsBody?.categoryBitMask = PhysicsCategories.Death
        saw.physicsBody?.collisionBitMask = 0
        saw.physicsBody?.contactTestBitMask = PhysicsCategories.player
        
        return saw
    }()
    
    lazy var sawBase: SKSpriteNode = {
        let baseTexture = SKTexture(imageNamed: "\(playerEra == .present ? "present-saw-base" : "future-saw-base")-1")
        return SKSpriteNode(texture: baseTexture, size: baseTexture.size())
    }()
    
    init(playerEra: PlayerEra, speed: CGFloat = 100, range: CGFloat = 400) {
        self.playerEra = playerEra
        self.sawSpeed = speed
        self.range = range
        
        super.init()
        
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setPosition()
        
        self.addChild(sawBase)
        sawBase.addChild(saw)
        
        
        moveSaw()
    }
    
    private func setPosition() {
        self.sawBase.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.sawBase.zPosition = 1
        
        self.saw.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.saw.position = CGPoint(x: 0, y: self.sawBase.size.height / 2)
        self.saw.zPosition = -1
        
        self.sawBase.xScale = 0.4
        self.sawBase.yScale = 0.4
    }
    
    private func moveSaw() {
        // Ponto inicial da serra
        let startPosition = self.position.x
        // Ponto final da serra baseado no range
        let endPosition = startPosition + range
        
        // Criando a ação de mover para a direita
        let moveRight = SKAction.moveTo(x: endPosition, duration: TimeInterval(range / sawSpeed))
        moveRight.timingMode = .easeInEaseOut
        
        // Criando a ação de mover para a esquerda
        let moveLeft = SKAction.moveTo(x: startPosition, duration: TimeInterval(range / sawSpeed))
        moveLeft.timingMode = .easeInEaseOut
        
        let wait = SKAction.wait(forDuration: 0.5)
        
        // Sequência de movimento da serra
        let moveSequence = SKAction.sequence([moveRight, wait, moveLeft, wait])
        
        // Ação que repete o movimento infinitamente
        let repeatMovement = SKAction.repeatForever(moveSequence)
        
        // Executa a animação de movimento
        sawBase.run(repeatMovement)
        
        let cut = SKAction.rotate(byAngle: .pi, duration: 0.4)
        
        saw.run(.repeatForever(cut))
    }
}

