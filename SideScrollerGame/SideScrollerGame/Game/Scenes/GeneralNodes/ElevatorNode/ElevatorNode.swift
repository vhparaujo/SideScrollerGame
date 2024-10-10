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
        
        self.maxHeight = maxHeight - platformTexture.size().height / 2
        
        return SKSpriteNode(texture: platformTexture, color: .blue, size: CGSize(width: 200, height: 50))
    }()
    
    lazy var moveButton: SKSpriteNode = {
        let moveButtonTexture = SKTexture(imageNamed: "\(playerEra == .present ? "elevator-body-present" : "player-idle-future")-1")
        
        return SKSpriteNode(texture: moveButtonTexture, color: .red, size: CGSize(width: 100, height: 100))
    }()
    
    var isMovingUp = false
    var maxHeight: CGFloat // Altura máxima que o elevador pode subir
    var minHeight: CGFloat = 0  // Altura mínima que o elevador pode descer
    
    init(playerEra: PlayerEra, mode: ElevatorMode, maxHeight: CGFloat) {
        self.playerEra = playerEra
        self.mode = mode
        self.maxHeight = maxHeight
        
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
            
            self.run(.repeatForever(.sequence([descer, esperar, subir])))
        }
    }
    
    // Movimento manual
    /// Movimento manual legado
///    func moveManual() {
///        let action: SKAction
///        if isMovingUp {
///            action = SKAction.moveBy(x: 0, y: 10, duration: 0.05)  // Movimento de subida
///        } else {
///            action = SKAction.moveBy(x: 0, y: -10, duration: 0.05)  // Movimento de descida
///        }
///
///        self.elevatorBody.run(.repeatForever(action), withKey: "manualMove")
///    }
///
///    func stopManualMove() {
///        self.elevatorBody.removeAction(forKey: "manualMove")
///    }
///
///    func updateMovement() {
///        // Verifica se está na altura máxima ou mínima
///        if elevatorBody.position.y >= maxHeight {
///            isMovingUp = false
///        } else if elevatorBody.position.y <= minHeight {
///            isMovingUp = true
///        }
///    }
    func moveManual() {
        self.elevatorBody.removeAction(forKey: "moveDown")
        
        // Verifica se o elevador já alcançou ou excedeu a altura máxima
        if elevatorBody.position.y < maxHeight {
            let moveUpAction = SKAction.moveBy(x: 0, y: 10, duration: 0.05)  // Movimento de subida
            let limitAction = SKAction.run { [weak self] in
                guard let self = self else { return }
                // Para o movimento ao atingir a altura máxima
                if self.elevatorBody.position.y >= self.maxHeight {
                    self.elevatorBody.position.y = self.maxHeight  // Garante que a altura máxima não seja ultrapassada
                    self.elevatorBody.removeAction(forKey: "manualMove")
                }
            }
            
            let sequence = SKAction.sequence([moveUpAction, limitAction])
            self.elevatorBody.run(.repeatForever(sequence), withKey: "manualMove")
        }
    }
    
    func stopManualMove() {
        self.elevatorBody.removeAction(forKey: "manualMove")
        
        let currentPosition = elevatorBody.position
        let distance = abs(currentPosition.y - .zero)  // Calcula a distância da posição original
        let duration = TimeInterval(distance / 200)  // Calcula a duração com base na distância e na velocidade

        let moveDownAction = SKAction.move(to: .zero, duration: duration)  // Ajusta a duração da descida
        self.elevatorBody.run(moveDownAction, withKey: "moveDown")
    }
    
    private func setupMoveButton() {
        // Physics
        self.moveButton.physicsBody = SKPhysicsBody(rectangleOf: (moveButton.texture?.size())!)
        
        moveButton.physicsBody?.affectedByGravity = false
        moveButton.physicsBody?.isDynamic = false
        moveButton.physicsBody?.friction = 0
        
        moveButton.physicsBody?.categoryBitMask = PhysicsCategories.moveButton
        moveButton.physicsBody?.collisionBitMask = 0
        moveButton.physicsBody?.contactTestBitMask = PhysicsCategories.player
        
        // Adding
        self.addChild(moveButton)
        
        // Position
        moveButton.position = CGPoint(x: -250, y: moveButton.size.height + elevatorBody.size.height)
    }
}

