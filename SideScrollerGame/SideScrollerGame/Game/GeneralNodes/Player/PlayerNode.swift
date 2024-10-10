//
//  PlayerNode.swift
//  SideScrollerGame
//
//  Created by Eduardo on 23/09/24.
//
import SpriteKit
import Combine


class PlayerNode: SKSpriteNode {
    
    internal var spawnPoint: CGPoint?
    
    internal var cancellables: [AnyCancellable] = []
    internal var controller: GameControllerManager {
        return GameControllerManager.shared
    }
    internal var playerEra: PlayerEra // Store the era for texture selection
    
    // Movement properties for the player
    internal var moveSpeed: CGFloat = 500.0
    let jumpImpulse: CGFloat = 7700 // Impulse applied to the player when jumping
    
    internal var playerInfo: PlayerInfo = .init(isMovingRight: false, isMovingLeft: false, textureState: .idle, facingRight: true, action: false, isGrounded: true, isJumping: false, alreadyJumping: false, isDying: false, position: .zero)
    
    internal var groundContactCount = 0 // Tracks number of ground contacts
    
    internal var currentPlatform: PlatformNode?
    
    var isPassedToPast = false
    
    //Box movement
    var boxRef: BoxNode?
    //    internal var isGrabbed = false
    internal var boxOffset: CGFloat = 0.0
    
    private var currentActionKey = "PlayerAnimation"
    
    var mpManager: MultiplayerManager
    
    init(playerEra: PlayerEra, mpManager: MultiplayerManager) {
        self.playerEra = playerEra // Initialize with the player era
        self.mpManager = mpManager
        
        // Start with the idle texture for the given era
        let texture = SKTexture(imageNamed: "\(playerEra == .present ? "player-idle-present" : "player-idle-future")-1")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.zPosition = 1
        // Set the default visual scale of the sprite
        self.setScale(4) // Adjust as needed
        
        setupPhysicsBody()
        setupBindings()
        changeState(to: .idle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPhysicsBody() {
        let bodySize = self.size
        
        self.physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategories.player
        self.physicsBody?.contactTestBitMask = PhysicsCategories.ground | PhysicsCategories.box | PhysicsCategories.wall
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
    
    func handleKeyPress(action: GameActions) {
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
                        playerInfo.action = true
                        box.isGrabbed = true
                        box.enableMovement()
                        boxOffset = box.position.x - self.position.x
                    }
                }
            case .brintToPresent:
                break
                
            default:
                break
        }
    }
    
    func callMovements() {
        if playerInfo.isMovingRight {
            playerInfo.facingRight = true
            if !playerInfo.action {
                self.xScale = abs(self.xScale)
            }
        }
        
        if playerInfo.isMovingLeft && !playerInfo.action{
            self.xScale = -abs(self.xScale)
        }
        
        if playerInfo.isMovingRight && !playerInfo.action {
            self.xScale = abs(self.xScale)
        }
        
        
    }
    
    
    
    // Handle key releases
    func handleKeyRelease(action: GameActions) {
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
                if playerInfo.action {
                    playerInfo.action = false
                    boxRef?.isGrabbed = false
                    boxRef?.disableMovement()
                }
            default:
                break
        }
    }
    
    // Update player position and animation based on movement direction
    func update(deltaTime: TimeInterval) {
//        
//        if playerInfo.isDying {
//            if let position = spawnPoint {
//                self.position = position
//                playerInfo.isDying = false
//            }
//        }
        
        sendPlayerInfoToOthers()
        callJump()
        callMovements()
        
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
        }else {
            changeState(to: .idle)
        }
    }
    
    func callJump() {
        if playerInfo.isJumping && !playerInfo.alreadyJumping && playerInfo.isGrounded && !playerInfo.action {
            self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
            playerInfo.isGrounded = false
            changeState(to: .jumping)
            playerInfo.isJumping = true
            playerInfo.alreadyJumping = true
        }
        
        if playerInfo.isGrounded {
            playerInfo.isJumping = false
            playerInfo.alreadyJumping = false
        }
    }
    
    // Função para enviar informações para outros jogadores
    private func sendPlayerInfoToOthers() {
        playerInfo.position = self.position
        
        mpManager.sendInfoToOtherPlayers(playerInfo: self.playerInfo)
    }
    
    // Change the player's animation state
    internal func changeState(to newState: PlayerTextureState) {
        if playerInfo.textureState == newState { return } // Avoid changing to the same state
        playerInfo.textureState = newState
        
        // Remove any existing animation
        self.removeAction(forKey: currentActionKey)
        
        // Get the appropriate textures based on the player era
        let textures = playerInfo.textureState.textures(for: playerEra)
        
        // Get the animation action
        let animationAction = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: playerInfo.textureState.timePerFrame))
        
        // Run the new animation
        self.run(animationAction, withKey: currentActionKey)
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let otherBody = (contact.bodyA.categoryBitMask == PhysicsCategories.player) ? contact.bodyB : contact.bodyA
        let otherCategory = otherBody.categoryBitMask
        
        if otherCategory == PhysicsCategories.ground || otherCategory == PhysicsCategories.box || otherCategory == PhysicsCategories.platform {
            groundContactCount += 1
            playerInfo.isGrounded = true
            playerInfo.isJumping = false
            playerInfo.alreadyJumping = false
            
            if otherCategory == PhysicsCategories.platform {
                currentPlatform = otherBody.node as? PlatformNode
            }
        }
        if otherCategory == PhysicsCategories.Death {
            triggerDeath()
        }
        
        if otherCategory == PhysicsCategories.spawnPoint {
            // Set the spawn point when the player touches it
            if let spawnNode = otherBody.node as? SpawnPointNode {
                self.spawnPoint = spawnNode.position
            }
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
        }
    }
    
    func triggerDeath() {
        playerInfo.isDying = true

        if let scene = self.scene as? FirstScene {
            // Create fade-in and fade-out actions
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            let resetPlayer = SKAction.run { [weak self] in
                if let spawnPoint = self?.spawnPoint {
                    self?.position = spawnPoint
                }
            }
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let sequence = SKAction.sequence([fadeIn, resetPlayer, fadeOut])

            // Run the sequence on the fade node
            scene.fadeNode.run(sequence)
        }
    }
}
