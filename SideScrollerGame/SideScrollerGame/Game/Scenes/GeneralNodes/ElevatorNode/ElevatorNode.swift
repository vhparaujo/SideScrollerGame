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
    let playerEra: PlayerEra
    let mode: ElevatorMode
    
    lazy var elevatorBody: SKSpriteNode = {
        #warning("depois tem q arrumar os nodes aq")
        let bodyTexture = SKTexture(imageNamed: "\(playerEra == .present ? "elevator-body-present" : "player-idle-future")-1")
        return SKSpriteNode(texture: bodyTexture, color: .red, size: CGSize(width: 200, height: 400))
    }()
    
    lazy var elevatorPlatform: SKSpriteNode = {
        #warning("depois tem q arrumar os nodes aq")
        let platformTexture = SKTexture(imageNamed: "\(playerEra == .present ? "elevator-platform-present" : "elevator-platform-future")-1")
        return SKSpriteNode(texture: platformTexture, color: .blue, size: CGSize(width: 200, height: 50))
    }()
    
    lazy var moveButton: SKSpriteNode = {
        let moveButtonTexture = SKTexture(imageNamed: "\(playerEra == .present ? "elevator-body-present" : "player-idle-future")-1")
        
        return SKSpriteNode(texture: moveButtonTexture, color: .red, size: CGSize(width: 200, height: 200))
    }()
    
    var isMovingUp = false
    var maxHeight: CGFloat = 800  // Altura máxima que o elevador pode subir
    var minHeight: CGFloat = 0    // Altura mínima que o elevador pode descer
    
    init(playerEra: PlayerEra, mode: ElevatorMode) {
        self.playerEra = playerEra
        self.mode = mode
        
        super.init()
        
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setPosition()
        setPhysicsBody()
        
        self.addChild(elevatorBody)
        elevatorBody.addChild(elevatorPlatform)
        
        if mode == .automatic {
            moveAutomatic()
        } else {
            setupMoveButton()
        }
    }
    
    private func setPhysicsBody() {
        elevatorPlatform.physicsBody = SKPhysicsBody(rectangleOf: elevatorPlatform.size)
        
        elevatorPlatform.physicsBody?.affectedByGravity = false
        elevatorPlatform.physicsBody?.isDynamic = false
        elevatorPlatform.physicsBody?.friction = 0
        
        elevatorPlatform.physicsBody?.categoryBitMask = PhysicsCategories.ground
        elevatorPlatform.physicsBody?.collisionBitMask = PhysicsCategories.player
        elevatorPlatform.physicsBody?.contactTestBitMask = PhysicsCategories.player
    }
    
    private func setPosition() {
        self.elevatorBody.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        self.elevatorPlatform.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.elevatorPlatform.position = CGPoint(x: 0, y: 400)
    }
    
    private func moveAutomatic() {
        if mode == .automatic {
            let subir = SKAction.move(by: CGVector(dx: 0, dy: Int(elevatorBody.size.height)), duration: 5)
            let descer = SKAction.move(by: CGVector(dx: 0, dy: Int(-elevatorBody.size.height)), duration: 5)
            let esperar = SKAction.wait(forDuration: 1)
            
            self.run(.repeatForever(.sequence([subir, esperar, descer])))
        }
    }
    
    // Movimento manual
    func moveManual() {
        let action: SKAction
        if isMovingUp {
            action = SKAction.moveBy(x: 0, y: 10, duration: 0.1)  // Movimento de subida
        } else {
            action = SKAction.moveBy(x: 0, y: -10, duration: 0.1)  // Movimento de descida
        }
        
        self.run(.repeatForever(action), withKey: "manualMove")
    }
    
    func stopManualMove() {
        self.removeAction(forKey: "manualMove")
    }
    
    func updateMovement() {
        // Verifica se está na altura máxima ou mínima
        if elevatorPlatform.position.y >= maxHeight {
            isMovingUp = false
        } else if elevatorPlatform.position.y <= minHeight {
            isMovingUp = true
        }
    }
    
    private func setupMoveButton() {
        self.moveButton.physicsBody = SKPhysicsBody(rectangleOf: (moveButton.texture?.size())!)
        
        moveButton.physicsBody?.affectedByGravity = false
        moveButton.physicsBody?.isDynamic = false
        moveButton.physicsBody?.friction = 0
        
        moveButton.physicsBody?.categoryBitMask = PhysicsCategories.ground
        moveButton.physicsBody?.collisionBitMask = 0
        moveButton.physicsBody?.contactTestBitMask = PhysicsCategories.player
    }
}

