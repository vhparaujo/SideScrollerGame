//
//  PlayerNode.swift
//  SideScrollerGame
//
//  Created by Eduardo on 23/09/24.
//
import SpriteKit
import Combine

class PlayerNode: SKSpriteNode {
    
    var cancellables = Set<AnyCancellable>()
    let controller = GameControllerManager.shared
    let playerEra: PlayerEra  // Store the era for texture selection
    
    // Movement properties for the player
    let moveSpeed: CGFloat = 500.0
    let jumpImpulse: CGFloat = 7700  // Impulse applied to the player when jumping
    
    var playerInfo = PlayerInfo(
        isMovingRight: false,
        isMovingLeft: false,
        textureState: .idle,
        facingRight: true,
        action: false,
        isGrounded: true,
        isJumping: false,
        alreadyJumping: false,
        isDying: false,
        position: .zero
    )
    
    var groundContactCount = 0  // Tracks number of ground contacts
    weak var currentPlatform: PlatformNode?
    var isPassedToPast = false
    var bringBoxToPresent = false
    // Box movement
    weak var boxRef: BoxNode?
    var boxOffset: CGFloat = 0.0
    
    weak var elevatorRef: ElevatorNode?
    
    var isOnLadder = false
    var canClimb = false
    var canDown = false
    
    var isOnFan = false
    
    var isFalling = false
    var alreadyFalling = false
    var lastHeightInGround: CGFloat = 0
    
    let currentActionKey = "PlayerAnimation"
    var mpManager: MultiplayerManager
    
    // Lazy property for fade-in effect during death
    lazy var fadeInDeath: SKSpriteNode = {
        let fadeIn = SKSpriteNode(color: .black, size: self.scene?.size ?? CGSize.zero)
        fadeIn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        fadeIn.alpha = 0
        fadeIn.zPosition = 1000
        return fadeIn
    }()
    
    init(playerEra: PlayerEra, mpManager: MultiplayerManager) {
        self.playerEra = playerEra
        self.mpManager = mpManager
        
    
        // Start with the idle texture for the given era
        let textureName = playerEra == .present ? "player-idle-present-1" : "player-idle-future-1"
        let texture = SKTexture(imageNamed: textureName)
        super.init(texture: texture, color: .clear, size: texture.size())
        self.zPosition = 1
        self.setScale(4)

        setupPhysicsBody()
        setupBindings()
        changeState(to: .idle)
    }
    
    required init?(coder aDecoder: NSCoder, playerEra: PlayerEra, mpManager: MultiplayerManager) {
        self.playerEra = playerEra
        self.mpManager = mpManager
        super.init(coder: aDecoder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysicsBody() {
        let bodySize = self.size
        self.physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategories.player
        self.physicsBody?.contactTestBitMask = PhysicsCategories.ground | PhysicsCategories.box | PhysicsCategories.wall | PhysicsCategories.ladder | PhysicsCategories.fan
        self.physicsBody?.collisionBitMask = PhysicsCategories.ground | PhysicsCategories.box | PhysicsCategories.platform | PhysicsCategories.wall
        self.physicsBody?.friction = 0.0
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.mass = 10.0
    }
    
    func setupBindings() {
        controller.keyPressPublisher
            .sink { action in
                self.handleKeyPress(action: action)
            }
            .store(in: &cancellables)
        
        controller.keyReleasePublisher
            .sink { action in
                self.handleKeyRelease(action: action)
            }
            .store(in: &cancellables)
    }
    
    private func handleKeyPress(action: GameActions) {
        switch action {
        case .moveLeft:
            playerInfo.isMovingLeft = true
            playerInfo.facingRight = false
        case .moveRight:
            playerInfo.isMovingRight = true
            playerInfo.facingRight = true
        case .jump:
            playerInfo.isJumping = true
        case .action:
            if playerInfo.isGrounded {
                if let box = boxRef {
                    if !box.isGrabbed {
                        playerInfo.action = true
                        box.isGrabbed = true
                        box.enableMovement()
                        boxOffset = box.position.x - self.position.x
                    }
                }
                if let elevator = elevatorRef {
                    playerInfo.action = true
                    elevator.moveManual()
                }
            }
        case .bringToPresent:
            bringBoxToPresent = true
        case .climb:
            canClimb = isOnLadder
        case .down:
            canDown = isOnLadder
        }
    }
    
    private func handleKeyRelease(action: GameActions) {
        switch action {
        case .moveLeft:
            playerInfo.isMovingLeft = false
        case .moveRight:
            playerInfo.isMovingRight = false
            if playerInfo.isMovingLeft {
                playerInfo.facingRight = false
                if !playerInfo.action {
                    self.xScale = -abs(self.xScale)
                }
            }
        case .action:
            if let box = boxRef {
                box.isGrabbed = false
            }
            if playerInfo.action {
                playerInfo.action = false
                boxRef?.isGrabbed = false
                boxRef?.disableMovement()
                elevatorRef?.stopManualMove()
            }
        case .bringToPresent:
            bringBoxToPresent = false
        case .climb:
            canClimb = false
        case .down:
            canDown = false
        default:
            break
        }
    }
    
    private func updatePlayerOrientation() {
        if playerInfo.isMovingRight && !playerInfo.action {
            self.xScale = abs(self.xScale)
        } else if playerInfo.isMovingLeft && !playerInfo.action {
            self.xScale = -abs(self.xScale)
        }
    }
    // Update player position and animation based on movement direction
    func update(deltaTime: TimeInterval) {
        sendPlayerInfoToOthers()
        handleJump()
        updatePlayerOrientation()
//        handleDeath()
        
        var desiredVelocity: CGFloat = 0.0
        
        if playerInfo.isMovingLeft && !playerInfo.isMovingRight {
            desiredVelocity = -moveSpeed
        } else if playerInfo.isMovingRight && !playerInfo.isMovingLeft {
            desiredVelocity = moveSpeed
        } else {
            desiredVelocity = 0.0
        }
        
        // Apply velocity to the player
        self.physicsBody?.velocity.dx = desiredVelocity
        
        // Move the box with the player when grabbed
        if playerInfo.action, let box = boxRef {
            // Maintain the initial offset captured during grabbing
            box.position.x = self.position.x + boxOffset
            box.physicsBody?.velocity.dx = desiredVelocity
            // Prevent the box from flipping
            box.xScale = abs(box.xScale)
        }
        
        // Adjust player's position by the platform's movement delta
        if let platform = currentPlatform {
            let delta = platform.movementDelta()
            self.position.x += delta.x
            self.position.y += delta.y
        }
        
        // Determine the appropriate state
        if playerInfo.action {
            changeState(to: .grabbing)
        } else if !playerInfo.isGrounded {
            changeState(to: .jumping)
        } else if desiredVelocity != 0 {
            changeState(to: .running)
        } else {
            changeState(to: .idle)
        }
        
        // Handle ladder movement
        if isOnLadder {
            if canClimb {
                self.position.y += 3 * CGFloat(deltaTime)
            } else if canDown {
                self.position.y -= 3 * CGFloat(deltaTime)
            }
        }
        
        // Handle death and respawn
        if playerInfo.isDying {
            triggerDeath()
        }
    }
    func handleDeath() {
        if isFalling && !alreadyFalling{
            alreadyFalling = true
            self.lastHeightInGround = self.position.y
        }
        
        else  {
            let value =  self.lastHeightInGround - self.position.y
            if value > 260 {
                print("value: \(value)")
                self.playerInfo.isDying = true
                self.lastHeightInGround = 0
            }
        }
    }

    private func handleJump() {
        if playerInfo.isJumping && !playerInfo.alreadyJumping && playerInfo.isGrounded && !playerInfo.action {
            self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
            playerInfo.isGrounded = false
            changeState(to: .jumping)
            playerInfo.alreadyJumping = true
        }
        
        if playerInfo.isGrounded {
            playerInfo.isJumping = false
            playerInfo.alreadyJumping = false
        }
    }
    
    // Send player info to other players
    private func sendPlayerInfoToOthers() {
        playerInfo.position = self.position
        mpManager.sendInfoToOtherPlayers(playerInfo: self.playerInfo)
    }
    
    // Change the player's animation state
    func changeState(to newState: PlayerTextureState) {
        if playerInfo.textureState == newState { return }  // Avoid changing to the same state
        playerInfo.textureState = newState
        
        // Remove any existing animation
        self.removeAction(forKey: currentActionKey)
        
        // Get the appropriate textures based on the player era
        let textures = playerInfo.textureState.textures(for: playerEra)
        
        // Get the animation action
        let animationAction = SKAction.repeatForever(
            SKAction.animate(with: textures, timePerFrame: playerInfo.textureState.timePerFrame)
        )
        
        // Run the new animation
        self.run(animationAction, withKey: currentActionKey)
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let otherBody = (contact.bodyA.categoryBitMask == PhysicsCategories.player) ? contact.bodyB : contact.bodyA
        let otherCategory = otherBody.categoryBitMask
        
        
        if otherCategory == PhysicsCategories.ground || otherCategory == PhysicsCategories.box || otherCategory == PhysicsCategories.platform || otherCategory == PhysicsCategories.wall{
            groundContactCount += 1
            playerInfo.isGrounded = true
            isFalling = false
            alreadyFalling = false
            playerInfo.isJumping = false
            playerInfo.alreadyJumping = false
            
            if otherCategory == PhysicsCategories.platform {
                currentPlatform = otherBody.node as? PlatformNode
            }
        }
        
        if otherCategory == PhysicsCategories.Death {
            triggerDeath()
        }
        
        if otherCategory == PhysicsCategories.spawnPoint, let spawnNode = otherBody.node as? SpawnPointNode {
            mpManager.sendInfoToOtherPlayers(content: spawnNode.position)
        }
        
        if otherCategory == PhysicsCategories.ladder {
            isOnLadder = true
            self.physicsBody?.affectedByGravity = false
        }
        
        if otherCategory == PhysicsCategories.fan {
            isOnFan = true
        }
        
        if otherCategory == PhysicsCategories.nextScene {
            GameViewModel.shared.transitionScene(to: .first(.future))
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let otherBody = (contact.bodyA.categoryBitMask == PhysicsCategories.player) ? contact.bodyB : contact.bodyA
        let otherCategory = otherBody.categoryBitMask
        
        if otherCategory == PhysicsCategories.ground || otherCategory == PhysicsCategories.box || otherCategory == PhysicsCategories.platform {
            groundContactCount = max(groundContactCount - 1, 0)
            if groundContactCount == 0 {
                playerInfo.isGrounded = false
            }
            
            if otherCategory == PhysicsCategories.platform {
                currentPlatform = nil
            }
            isFalling = true
        }
        
        if otherCategory == PhysicsCategories.ladder {
            isOnLadder = false
            self.physicsBody?.affectedByGravity = true
        }
        
        if otherCategory == PhysicsCategories.fan {
            isOnFan = false
        }
    
    }
    
    private func triggerDeath() {
        playerInfo.isDying = true
        self.physicsBody?.velocity = .zero
        
        // Add fade-in effect to the scene
        if let scene = self.scene, fadeInDeath.parent == nil {
            scene.addChild(fadeInDeath)
            fadeInDeath.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        }
        
        // Create fade-in and fade-out actions
        let fadeInAction = SKAction.fadeAlpha(to: 1.0, duration: 1.0)
        let waitAction = SKAction.wait(forDuration: 0.5)
        let resetPlayerAction = SKAction.run {
            
            self.position = self.mpManager.spawnpoint
            
            self.playerInfo.isDying = false
        }
        let fadeOutAction = SKAction.fadeAlpha(to: 0.0, duration: 1.0)
        let removeFadeInDeath = SKAction.removeFromParent()
        let fadeSequence = SKAction.sequence([fadeInAction, waitAction, resetPlayerAction, fadeOutAction, removeFadeInDeath])
        
        fadeInDeath.run(fadeSequence)
    }
}
