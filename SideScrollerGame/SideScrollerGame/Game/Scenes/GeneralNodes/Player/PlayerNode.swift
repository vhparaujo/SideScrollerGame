//
//  PlayerNode.swift
//  SideScrollerGame
//
//  Created by Eduardo on 23/09/24.
//
import SpriteKit
import Combine


class PlayerNode: SKSpriteNode {
    
    internal var cancellables: [AnyCancellable] = []
    internal var controller: GameController = GameController()
    internal var playerEra: PlayerEra // Store the era for texture selection
    
    // Movement properties for the player
    internal var moveSpeed: CGFloat = 500.0
    let jumpImpulse: CGFloat = 1000.0 // Impulse applied to the player when jumping
    
//    internal var playerInfo: PlayerInfo = .init(isMovingRight: false, isMovingLeft: false, state: .idle, facingRight: false, isGrabbed: false, isGrounded: true, isJumping: false)
    
    internal var isMovingLeft = false
    internal var isMovingRight = false
    internal var isGrounded = true
    internal var groundContactCount = 0 // Tracks number of ground contacts
    internal var isJumping = false
    internal var facingRight = true // Tracks the orientation
    internal var currentPlatform: PlatformNode?
    
    //Box movement
    var boxRef: BoxNode?
    internal var isGrabbed = false
    internal var boxOffset: CGFloat = 0.0
    
    // Keep track of current action to avoid restarting the animation
    internal var currentState: PlayerTextureState = .idle
    private var currentActionKey = "PlayerAnimation"
    
    var mpManager: MultiplayerManager

    init(playerEra: PlayerEra, mpManager: MultiplayerManager) {
        self.playerEra = playerEra // Initialize with the player era
        self.mpManager = mpManager
        
        // Start with the idle texture for the given era
        let texture = SKTexture(imageNamed: "\(playerEra == .present ? "player-idle-present" : "player-idle-future")-1")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.zPosition = 1
        self.setScale(5)
        
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
        self.physicsBody?.contactTestBitMask = PhysicsCategories.ground | PhysicsCategories.box
        self.physicsBody?.collisionBitMask = PhysicsCategories.ground | PhysicsCategories.box | PhysicsCategories.platform
        self.physicsBody?.friction = 1.0
        self.physicsBody?.restitution = 0.0
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
                isMovingLeft = true
                facingRight = false
                if !isGrabbed {
                    self.xScale = -abs(self.xScale)
                }
            case .moveRight:
                isMovingRight = true
                facingRight = true
                if !isGrabbed {
                    self.xScale = abs(self.xScale)
                }
            case .jump:
            if isGrounded, !isGrabbed{
                    self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
                    isGrounded = false
                    changeState(to: .jumping)
                    isJumping = true
                }
            case .grab:
                if isGrounded {
                    if let box = boxRef {
                        isGrabbed = true
                        box.isGrabbed = true
                        box.enableMovement()
                        boxOffset = box.position.x - self.position.x
                    }
                }
            default:
                break
        }
    }
    
    
    
    // Handle key releases
    func handleKeyRelease(action: GameActions) {
        switch action {
            case .moveLeft:
                isMovingLeft = false
                if isMovingRight {
                    facingRight = true
                    if !isGrabbed {
                        self.xScale = abs(self.xScale)
                    }
                }
            case .moveRight:
                isMovingRight = false
                if isMovingLeft {
                    facingRight = false
                    if !isGrabbed {
                        self.xScale = -abs(self.xScale)
                    }
                }
            case .grab:
                if isGrabbed {
                    isGrabbed = false
                    boxRef?.isGrabbed = false
                    boxRef?.disableMovement()
                }
            default:
                break
        }
    }
    
    // Update player position and animation based on movement direction
    func update(deltaTime: TimeInterval) {
        
        sendPlayerInfoToOthers()

        var desiredVelocity: CGFloat = 0.0
        
        if isMovingLeft && !isMovingRight {
            desiredVelocity = -moveSpeed
        } else if isMovingRight && !isMovingLeft {
            desiredVelocity = moveSpeed
        } else {
            desiredVelocity = 0.0
        }
        
        // Apply velocity to the player
        self.physicsBody?.velocity.dx = desiredVelocity
        
        // Move the box with the player when grabbed
        if isGrabbed, let box = boxRef {
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
        if isGrabbed {
            changeState(to: .grabbing)
        } else if !isGrounded {
            changeState(to: .jumping)
        } else if desiredVelocity != 0 {
            changeState(to: .running)
        } else {
            changeState(to: .idle)
        }
    }
    
    // Change the player's animation state
    internal func changeState(to newState: PlayerTextureState) {
        if currentState == newState { return } // Avoid changing to the same state
        currentState = newState
        
        // Remove any existing animation
        self.removeAction(forKey: currentActionKey)
        
        // Get the appropriate textures based on the player era
        let textures = currentState.textures(for: playerEra)
        
        // Get the animation action
        let animationAction = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: currentState.timePerFrame))
        
        // Run the new animation
        self.run(animationAction, withKey: currentActionKey)
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let otherBody = (contact.bodyA.categoryBitMask == PhysicsCategories.player) ? contact.bodyB : contact.bodyA
        let otherCategory = otherBody.categoryBitMask

        if otherCategory == PhysicsCategories.ground || otherCategory == PhysicsCategories.box || otherCategory == PhysicsCategories.platform {
            groundContactCount += 1
            isGrounded = true
            isJumping = false

            if otherCategory == PhysicsCategories.platform {
                currentPlatform = otherBody.node as? PlatformNode
            }
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let otherBody = (contact.bodyA.categoryBitMask == PhysicsCategories.player) ? contact.bodyB : contact.bodyA
        let otherCategory = otherBody.categoryBitMask

        if otherCategory == PhysicsCategories.ground || otherCategory == PhysicsCategories.box || otherCategory == PhysicsCategories.platform {
            groundContactCount = max(groundContactCount - 1, 0)
            
            if groundContactCount == 0 {
                isGrounded = false
            }

            if otherCategory == PhysicsCategories.platform {
                currentPlatform = nil
            }
        }
    }
    
    func getCurrentState() -> PlayerTextureState {
        return currentState
    }
    
    func getFacingRight() -> Bool {
        return facingRight
    }
    
    func getIsGrounded() -> Bool {
        return isGrounded
    }
    
    func getIsGrabbed() -> Bool {
        return isGrabbed
    }
    
    // Função para gerar as informações atuais do jogador
       private func generatePlayerInfo() -> PlayerInfo {
           let playerInfo = PlayerInfo(
            isMovingRight: isMovingRight,
            isMovingLeft: isMovingLeft,
            state: currentState,
            facingRight: facingRight,
            isGrabbed: isGrabbed,
            isGrounded: isGrounded,
            isJumping: isJumping
        )
           return playerInfo
       }
       
       // Função para enviar informações para outros jogadores
       private func sendPlayerInfoToOthers() {
           let playerInfo = generatePlayerInfo()
           mpManager.sendInfoToOtherPlayers(playerInfo: playerInfo) 
       }
}
