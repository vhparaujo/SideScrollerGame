import SpriteKit

enum ElevatorMode {
    case automatic
    case manual
}

class ElevatorNode: SKNode {
    let playerEra: PlayerEra
    let mode: ElevatorMode
    
    lazy var elevatorLever: SKSpriteNode = {
        let interruptorTexture = SKTexture(imageNamed: playerEra == .present ? "elevator-lever" : "elevator-future-lever")
        let interruptor = SKSpriteNode(texture: interruptorTexture, size: CGSize(width: objectWidth * factor, height: objectHeight * 0.25 * factor))
        
        return interruptor
    }()
    
    lazy var elevatorPlatform: SKSpriteNode = {
        let platformTexture = SKTexture(imageNamed: playerEra == .present ? "elevator-top" : "elevator-future-top")
        let platform = SKSpriteNode(texture: platformTexture, size: CGSize(width: objectWidth * factor, height: objectHeight * 0.25 * factor))
        
        return platform
    }()
    
    lazy var elevatorBodyButton: SKSpriteNode = {
        let buttonTexture = SKTexture(imageNamed: playerEra == .present ? "elevator-bottom-off" : "elevator-future-bottom-off")
        return SKSpriteNode(texture: buttonTexture, size: CGSize(width: objectWidth * factor, height: objectHeight * 0.75 * factor))
    }()
    
    lazy var underPlatform: SKSpriteNode = {
        let bodyTexture = SKTexture(imageNamed: playerEra == .present ? "elevator-middle" : "elevator-future-middle")
        return SKSpriteNode(texture: bodyTexture, size: CGSize(width: objectWidth * 0.8 * factor, height: objectHeight * factor))
    }()
    
    private lazy var elevatorContainer: SKNode = {
        let container = SKNode()
        let padding = 0.76
        
        let firstUnderPlatform = underPlatform
        firstUnderPlatform.position = CGPoint(x: 0, y: elevatorBodyButton.position.y)
        container.addChild(firstUnderPlatform)
        
        let secondUnderPlatform = SKSpriteNode(texture: firstUnderPlatform.texture, size: firstUnderPlatform.size)
        secondUnderPlatform.position = CGPoint(x: 0, y: firstUnderPlatform.position.y - firstUnderPlatform.size.height * padding)
        container.addChild(secondUnderPlatform)
        
        let thirdUnderPlatform = SKSpriteNode(texture: firstUnderPlatform.texture, size: firstUnderPlatform.size)
        thirdUnderPlatform.position = CGPoint(x: 0, y: secondUnderPlatform.position.y - secondUnderPlatform.size.height * padding)
        container.addChild(thirdUnderPlatform)

        firstUnderPlatform.addChild(elevatorPlatform)
        
        return container
    }()
      
    var isMovingUp = false
    var maxHeight: CGFloat
    var minHeight: CGFloat = 0
    
    var factor = 0.7
    var objectHeight = 200.0
    var objectWidth = 200.0

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
        
        setPhysicsBody()
        
        if mode == .automatic {
            moveAutomatic()
        } else {
            setupMoveButton()
        }
    }
    
    

    private func moveAutomatic() {
        let moveUp = SKAction.moveBy(x: 0, y: underPlatform.size.height, duration: 5)
        let moveDown = SKAction.moveBy(x: 0, y: -underPlatform.size.height, duration: 5)
        let wait = SKAction.wait(forDuration: 1)
        let sequence = SKAction.sequence([moveDown, wait, moveUp])
        
        elevatorContainer.run(.repeatForever(sequence))
    }
    
    func moveManual() {
        elevatorContainer.removeAction(forKey: "moveDown")
        maxHeight = maxHeight * factor
        
        if elevatorContainer.position.y < maxHeight {
            let moveUpAction = SKAction.moveBy(x: 0, y: 10, duration: 0.05)
            let limitAction = SKAction.run { [weak self] in
                guard let self = self else { return }
                if self.elevatorContainer.position.y >= self.maxHeight {
                    self.elevatorContainer.position.y = self.maxHeight
                    self.elevatorContainer.removeAction(forKey: "manualMove")
                }
                self.elevatorBodyButton.texture = SKTexture(imageNamed: self.playerEra == .present ? "elevator-bottom-on" : "elevator-future-bottom-on")
            }
            let sequence = SKAction.sequence([moveUpAction, limitAction])
            elevatorContainer.run(.repeatForever(sequence), withKey: "manualMove")
        }
    }
    
    func stopManualMove() {
        elevatorContainer.removeAction(forKey: "manualMove")
        
        let currentPosition = elevatorContainer.position
        let distance = abs(currentPosition.y - minHeight)
        let duration = TimeInterval(distance / 200)
        let moveDownAction = SKAction.move(to: CGPoint(x: currentPosition.x, y: minHeight), duration: duration)
        
        let setTextureOffAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            self.elevatorBodyButton.texture = SKTexture(imageNamed: self.playerEra == .present ? "elevator-bottom-off" : "elevator-future-bottom-off")
        }
        
        let sequence = SKAction.sequence([moveDownAction, setTextureOffAction])
        elevatorContainer.run(sequence, withKey: "moveDown")
    }
    
    private func setPhysicsBody() {
        
        elevatorPlatform.physicsBody = SKPhysicsBody(rectangleOf: elevatorPlatform.size)
        elevatorPlatform.physicsBody?.affectedByGravity = false
        elevatorPlatform.physicsBody?.isDynamic = false
        elevatorPlatform.physicsBody?.friction = 0
        elevatorPlatform.physicsBody?.categoryBitMask = PhysicsCategories.ground
        elevatorPlatform.physicsBody?.collisionBitMask = PhysicsCategories.player
        elevatorPlatform.physicsBody?.contactTestBitMask = PhysicsCategories.player

        let m = 70.0
        let b = 20 - m * 0.8

        elevatorBodyButton.position.y = m * factor + b

        elevatorPlatform.position.y = elevatorBodyButton.position.y + ((elevatorBodyButton.frame.height / 2) )
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
//        elevatorBodyButton.position.y += 35
        
        addChild(elevatorContainer)
        addChild(elevatorBodyButton)
    }
}
