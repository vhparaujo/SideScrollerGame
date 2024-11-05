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
        return SKSpriteNode(texture: bodyTexture, size: CGSize(width: 200, height: 400))
    }()
    
    lazy var elevatorPlatform: SKSpriteNode = {
        let platformTexture = SKTexture(imageNamed: playerEra == .present ? "elevator-top" : "elevator-future-top")
        let platform = SKSpriteNode(texture: platformTexture, size: CGSize(width: 200, height: 50))
        
        maxHeight -= platformTexture.size().height / 2  // Ajusta altura máxima com base na altura da plataforma
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
        elevatorPlatform.position = CGPoint(x: 0, y: underPlatform.size.height / 2)
        underPlatform.position = CGPoint(x: 0, y: 0)
        elevatorBodyButton.position = CGPoint(x: 0, y: 10)
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
        underPlatform.run(moveDownAction, withKey: "moveDown")
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
