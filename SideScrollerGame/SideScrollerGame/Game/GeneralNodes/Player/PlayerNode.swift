import SpriteKit
import Combine

class PlayerNode: SKSpriteNode {
    
    var cancellables = Set<AnyCancellable>()
    let controller = GameControllerManager.shared
    let playerEra: PlayerEra
    var mpManager: MultiplayerManager
    
    // Movement properties
    let moveSpeed: CGFloat = 500.0
    let jumpImpulse: CGFloat = 7700.0
    
    var playerInfo = PlayerInfo(
        textureState: .idle,
        facingRight: true,
        action: false,
        isDying: false,
        position: .zero
    )
    
    private var isMovingLeft = false
    private var isMovingRight = false
    
    private var isGrounded = false
    private var isJumping = false
    weak var currentPlatform: PlatformNode?
    
    // Box interaction
    weak var boxRef: BoxNode?
    private var boxOffset: CGFloat = 0.0
    
    weak var elevatorRef: ElevatorNode?
    
    
    var bringBoxToPresent = false
    // Ladder interaction
    var isOnLadder = false
    var canClimb = false
    var canDescend = false
    
    // Fan interaction
    var isOnFan = false
    
    let currentActionKey = "PlayerAnimation"
    
    // Fade-in effect for death
    private lazy var fadeInDeath: SKSpriteNode = {
        let fadeIn = SKSpriteNode(color: .black, size: self.scene?.size ?? .zero)
        fadeIn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        fadeIn.alpha = 0
        fadeIn.zPosition = 1000
        return fadeIn
    }()
    
    init(playerEra: PlayerEra, mpManager: MultiplayerManager) {
        self.playerEra = playerEra
        self.mpManager = mpManager
        
        let textureName = playerEra == .present ? "player-idle-present-1" : "player-idle-future-1"
        let texture = SKTexture(imageNamed: textureName)
        super.init(texture: texture, color: .clear, size: texture.size())
        self.zPosition = 1
        self.setScale(4)
        
        setupPhysicsBody()
        setupBindings()
        changeState(to: .idle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysicsBody() {
        let bodySize = self.size
        physicsBody = createRoundedRectanglePhysicsBody(tileSize: bodySize)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = true
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategories.player
        physicsBody?.contactTestBitMask = PhysicsCategories.ground | PhysicsCategories.box | PhysicsCategories.wall | PhysicsCategories.ladder | PhysicsCategories.fan
        physicsBody?.collisionBitMask = PhysicsCategories.ground | PhysicsCategories.box | PhysicsCategories.platform | PhysicsCategories.wall
        physicsBody?.friction = 0.0
        physicsBody?.restitution = 0.0
        physicsBody?.mass = 10.0
    }
    
    func createRoundedRectanglePhysicsBody(tileSize: CGSize) -> SKPhysicsBody? {
        // Define the rectangle centered at (0,0) since the node's position is set accordingly
        let rect = CGRect(x: -tileSize.width / 2, y: -tileSize.height / 2, width: tileSize.width, height: tileSize.height)
        // Define the corner radius (adjust as needed)
        let cornerRadius = min(tileSize.width, tileSize.height) * 0.2 // 20% of the smallest dimension
        // Create the rounded rectangle path
        let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        // Create the physics body from the path
        let physicsBody = SKPhysicsBody(polygonFrom: path)
        // Enable precise collision detection if necessary
        physicsBody.usesPreciseCollisionDetection = true
        return physicsBody
    }
    private func setupBindings() {
        controller.keyPressPublisher
            .sink { [weak self] action in
                self?.handleKeyPress(action: action)
            }
            .store(in: &cancellables)
        
        controller.keyReleasePublisher
            .sink { [weak self] action in
                self?.handleKeyRelease(action: action)
            }
            .store(in: &cancellables)
    }
    
    private func handleKeyPress(action: GameActions) {
        switch action {
            case .moveLeft:
                isMovingLeft = true
                playerInfo.facingRight = false
            case .moveRight:
                isMovingRight = true
                playerInfo.facingRight = true
            case .jump:
                if isGrounded && !playerInfo.action {
                    isJumping = true
                }
            case .action:
                handleActionKeyPress()
            case .bringToPresent:
                // Handle bring to present logic if needed
                bringBoxToPresent = true
            case .climb:
                canClimb = isOnLadder
            case .down:
                canDescend = isOnLadder
        }
    }
    
    private func handleKeyRelease(action: GameActions) {
        switch action {
            case .moveLeft:
                isMovingLeft = false
            case .moveRight:
                isMovingRight = false
            case .action:
                handleActionKeyRelease()
            case .bringToPresent:
                // Handle bring to present logic if needed
                bringBoxToPresent = false
            case .climb:
                canClimb = false
            case .down:
                canDescend = false
            case .jump:
                break
        }
    }
    
    private func handleActionKeyPress() {
        if isGrounded {
            if let box = boxRef, !box.isGrabbed {
                playerInfo.action = true
                box.isGrabbed = true
                box.enableMovement()
                boxOffset = box.position.x - self.position.x
            } else if let elevator = elevatorRef {
                playerInfo.action = true
                elevator.moveManual()
            }
        }
    }
    
    private func handleActionKeyRelease() {
        if let box = boxRef {
            box.isGrabbed = false
            box.disableMovement()
        }
        if let elevator = elevatorRef {
            elevator.stopManualMove()
        }
        playerInfo.action = false
    }
    
    private func updatePlayerOrientation() {
        guard !playerInfo.action else { return }
        if playerInfo.facingRight {
            xScale = abs(xScale)
        } else {
            xScale = -abs(xScale)
        }
    }
    func checkForNearbyBox() -> BoxNode? {
        let pickUpRange: CGFloat = 150
        let pickUpRangeHeight: CGFloat = self.frame.height * 0.98
        let nearbyNodes = self.scene?.children ?? []
        
        for node in nearbyNodes {

            if let box = node as? BoxNode {
                
                let distanceToBox = abs(box.position.x - self.position.x)
                let distanceHeithgToBox = abs(box.position.y - self.position.y)
                if distanceToBox <= pickUpRange, distanceHeithgToBox <= pickUpRangeHeight{
                    if (self.xScale > 0 && box.position.x > self.position.x) ||
                       (self.xScale < 0 && box.position.x < self.position.x) {
                        return box  // Retorna a caixa se estiver dentro do alcance e à frente do jogador
                    }
                }
            }
        }
        return nil
    }


    
    func update(deltaTime: TimeInterval) {
        self.boxRef = checkForNearbyBox()
        sendPlayerInfoToOthers()
        handleJump()
        handleDeath()
        updatePlayerOrientation()
        
        var desiredVelocity: CGFloat = 0.0
        
        if isMovingLeft {
            desiredVelocity = -moveSpeed
        } else if isMovingRight {
            desiredVelocity = moveSpeed
        }
        
        physicsBody?.velocity.dx = desiredVelocity
        
        // Move the box with the player when grabbed
        if playerInfo.action, let box = boxRef {
            box.position.x = self.position.x + boxOffset
            box.physicsBody?.velocity.dx = desiredVelocity
            box.xScale = abs(box.xScale)
        }
        
        // Adjust player's position by the platform's movement delta
        if let platform = currentPlatform {
            let delta = platform.movementDelta()
            position.x += delta.x
            position.y += delta.y
        }
        
        // Update animation state
        if playerInfo.action {
            changeState(to: .grabbing)
        } else if !isGrounded {
            changeState(to: .jumping)
        } else if desiredVelocity != 0 {
            changeState(to: .running)
        } else {
            changeState(to: .idle)
        }
        
        // Handle ladder movement
        if isOnLadder {
            physicsBody?.affectedByGravity = false
            if canClimb {
                position.y += 300 * CGFloat(deltaTime)
            } else if canDescend {
                position.y -= 300 * CGFloat(deltaTime)
            }
        } else {
            physicsBody?.affectedByGravity = true
        }
        
        // Handle death and respawn
        if playerInfo.isDying {
            triggerDeath()
        }
    }
    
    private func handleDeath() {
        if playerInfo.isDying {
            self.position = mpManager.spawnpoint
            playerInfo.isDying = false
        }
    }

    private func handleJump() {
        if isJumping && isGrounded {
            physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
            isGrounded = false
            isJumping = true
            changeState(to: .jumping)
        }
    }
    
    private func sendPlayerInfoToOthers() {
        playerInfo.position = position
        mpManager.sendInfoToOtherPlayers(playerInfo: playerInfo)
    }
    
    func changeState(to newState: PlayerTextureState) {
        guard playerInfo.textureState != newState else { return }
        playerInfo.textureState = newState
        
        removeAction(forKey: currentActionKey)
        
        let textures = playerInfo.textureState.textures(for: playerEra)
        let animationAction = SKAction.repeatForever(
            SKAction.animate(with: textures, timePerFrame: playerInfo.textureState.timePerFrame)
        )
        
        run(animationAction, withKey: currentActionKey)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let otherBody = (contact.bodyA.categoryBitMask == PhysicsCategories.player) ? contact.bodyB : contact.bodyA
        let otherCategory = otherBody.categoryBitMask
        
        if otherCategory & (PhysicsCategories.ground | PhysicsCategories.box | PhysicsCategories.platform) != 0 {
            isGrounded = true
            
            if otherCategory == PhysicsCategories.platform {
                currentPlatform = otherBody.node as? PlatformNode
            }
        }
        
        if otherCategory == PhysicsCategories.spawnPoint {
          if let spanwPointNode = otherBody.node as? SpawnPointNode {
              mpManager.sendInfoToOtherPlayers(content: spanwPointNode.position)
            }
        }
        
        if otherCategory == PhysicsCategories.Death {
            triggerDeath()
        }
        
        if otherCategory == PhysicsCategories.ladder {
            isOnLadder = true
        }
        
        if otherCategory == PhysicsCategories.fan {
            isOnFan = true
        }
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let otherBody = (contact.bodyA.categoryBitMask == PhysicsCategories.player) ? contact.bodyB : contact.bodyA
        let otherCategory = otherBody.categoryBitMask
        
        if otherCategory & (PhysicsCategories.ground | PhysicsCategories.box | PhysicsCategories.platform) != 0 {
            
            if otherCategory == PhysicsCategories.ground {
                isGrounded = false
            }
            
            if otherCategory == PhysicsCategories.platform {
                currentPlatform = nil
            }
        }
        
        if otherCategory == PhysicsCategories.ladder {
            isOnLadder = false
        }
        
        if otherCategory == PhysicsCategories.fan {
            isOnFan = false
        }
    }
    
    func triggerDeath() {
        playerInfo.isDying = true
    }
}
