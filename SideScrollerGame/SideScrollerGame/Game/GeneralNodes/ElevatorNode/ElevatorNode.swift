import SpriteKit

enum ElevatorMode {
    case automatic
    case manual
}

class ElevatorNode: SKNode {
    let playerEra: PlayerEra
    let mode: ElevatorMode
      
    lazy var underPlatform: SKSpriteNode = {
        let bodyTexture = SKTexture(imageNamed: playerEra == .present ? "elevator-middle" : "elevator-future-middle")
        return SKSpriteNode(texture: bodyTexture, size: CGSize(width: 185, height: 200))
    }()
    
    lazy var elevatorPlatform: SKSpriteNode = {
        let platformTexture = SKTexture(imageNamed: playerEra == .present ? "elevator-top" : "elevator-future-top")
        let platform = SKSpriteNode(texture: platformTexture, size: CGSize(width: 200, height: 50))
        
        maxHeight -= platformTexture.size().height / 2 
        return platform
    }()
    
    lazy var elevatorBodyButton: SKSpriteNode = {
        let buttonTexture = SKTexture(imageNamed: playerEra == .present ? "elevator-bottom-off" : "elevator-future-bottom-off")
        return SKSpriteNode(texture: buttonTexture, size: CGSize(width: 200, height: 150))
    }()
    
    var isMovingUp = false
    var maxHeight: CGFloat
    var minHeight: CGFloat = 0

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
        self.name = "elevator\(UUID())"
        setPosition()
        setPhysicsBody()
        
        addChild(underPlatform)
        underPlatform.addChild(elevatorPlatform)
        
        if mode == .automatic {
            moveAutomatic()
        } else {
            setupMoveButton()
        }
    }
    
//    private func setup() {
//        setPosition()
//        setPhysicsBody()
//        
//        var currentHeight: CGFloat = 0
//        
//        // Loop para adicionar múltiplos underPlatform até atingir 800 de altura
//        while currentHeight < 800 {
//            let newUnderPlatform = SKSpriteNode(texture: underPlatform.texture, size: underPlatform.size)
//            newUnderPlatform.position = CGPoint(x: 0, y: currentHeight)
//            addChild(newUnderPlatform)
//            
//            currentHeight += newUnderPlatform.size.height
//        }
//        
//        // Adiciona o elevador e o botão à plataforma superior
//        addChild(elevatorPlatform)
//        
//        if mode == .automatic {
//            moveAutomatic()
//        } else {
//            setupMoveButton()
//        }
//    }

    
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
        elevatorPlatform.position = CGPoint(x: self.position.x, y: elevatorBodyButton.size.height - 15)
        underPlatform.position = CGPoint(x: self.position.x, y: 0)
        elevatorBodyButton.position = CGPoint(x: 0, y: 35)
    }
    
    private func moveAutomatic() {
        let moveUp = SKAction.moveBy(x: 0, y: underPlatform.size.height, duration: 5)
        let moveDown = SKAction.moveBy(x: 0, y: -underPlatform.size.height, duration: 5)
        let wait = SKAction.wait(forDuration: 1)
        let sequence = SKAction.sequence([moveDown, wait, moveUp])
        self.run(.repeatForever(sequence))
    }
    
    // Movimento manual
    func moveManual() {
        underPlatform.removeAction(forKey: "moveDown")
        
        if underPlatform.position.y < maxHeight {
            let moveUpAction = SKAction.moveBy(x: 0, y: 10, duration: 0.05)
            let limitAction = SKAction.run { [weak self] in
                guard let self = self else { return }
                if self.underPlatform.position.y >= self.maxHeight {
                    self.underPlatform.position.y = self.maxHeight
                    self.underPlatform.removeAction(forKey: "manualMove")
                }
                self.elevatorBodyButton.texture = SKTexture(imageNamed: playerEra == .present ? "elevator-bottom-on" : "elevator-future-bottom-on")
            }
            let sequence = SKAction.sequence([moveUpAction, limitAction])
            underPlatform.run(.repeatForever(sequence), withKey: "manualMove")
        }

    }
    
    func stopManualMove() {
        underPlatform.removeAction(forKey: "manualMove")
        
        let currentPosition = underPlatform.position
        let distance = abs(currentPosition.y - minHeight)
        let duration = TimeInterval(distance / 200)
        let moveDownAction = SKAction.move(to: CGPoint(x: currentPosition.x, y: minHeight), duration: duration)
        
        let setTextureOffAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            self.elevatorBodyButton.texture = SKTexture(imageNamed: self.playerEra == .present ? "elevator-bottom-off" : "elevator-future-bottom-off")
        }
        
        // Executa o movimento e depois altera a textura
        let sequence = SKAction.sequence([moveDownAction, setTextureOffAction])
        underPlatform.run(sequence, withKey: "moveDown")
    }

    
    private func setupMoveButton() {
        elevatorBodyButton.physicsBody = SKPhysicsBody(rectangleOf: elevatorBodyButton.size)
        elevatorBodyButton.physicsBody?.affectedByGravity = false
        elevatorBodyButton.physicsBody?.isDynamic = true
        elevatorBodyButton.physicsBody?.mass = 100000000
        elevatorBodyButton.physicsBody?.friction = 0
        elevatorBodyButton.physicsBody?.categoryBitMask = PhysicsCategories.moveButton
        elevatorBodyButton.physicsBody?.collisionBitMask = 0
        elevatorBodyButton.physicsBody?.contactTestBitMask = PhysicsCategories.player
        
        addChild(elevatorBodyButton)
    }
}
