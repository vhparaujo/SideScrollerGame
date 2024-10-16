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
        #warning("depois tem q arrumar os nodes aq")
        let bodyTexture = SKTexture(imageNamed: "\(playerEra == .present ? "saw-present" : "saw-future")-1")
        return SKSpriteNode(texture: bodyTexture, color: .red, size: CGSize(width: 200, height: 200))
    }()
    
    init(playerEra: PlayerEra, speed: CGFloat = 0, range: CGFloat = 0) {
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
        setPhysicsBody()
        
        self.addChild(saw)
        
        moveSaw()
    }
    
    private func setPhysicsBody() {
        saw.physicsBody = SKPhysicsBody(rectangleOf: saw.size)
        
        saw.physicsBody?.affectedByGravity = false
        saw.physicsBody?.isDynamic = false
        saw.physicsBody?.friction = 0
        
        saw.physicsBody?.categoryBitMask = PhysicsCategories.Death
        saw.physicsBody?.collisionBitMask = 0
        saw.physicsBody?.contactTestBitMask = PhysicsCategories.player
    }
    
    private func setPosition() {
        self.saw.anchorPoint = CGPoint(x: 0.5, y: 0.5)
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
        saw.run(repeatMovement)
    }
}

