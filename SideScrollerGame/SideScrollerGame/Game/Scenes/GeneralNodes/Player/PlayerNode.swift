//
//  PlayerNode.swift
//  SideScrollerGame
//
//  Created by Eduardo on 23/09/24.
//
import SpriteKit
import Combine

class PlayerNode: SKSpriteNode {
    
    private var cancellables: [AnyCancellable] = []
    private var controller: GameController = GameController()
    private var playerEra: PlayerEra // Store the era for texture selection
    
    // Movement properties for the player
    private var moveSpeed: CGFloat = 500.0
    let jumpImpulse: CGFloat = 1000.0 // Impulse applied to the player when jumping
    
    
    private var isMovingLeft = false
    private var isMovingRight = false
    private var isGrounded = true
    private var groundContactCount = 0 // Tracks number of ground contacts
    
    private var facingRight = true // Tracks the orientation
    
    //Box movement
    var boxRef: BoxNode?
    private var isGrabbed = false {
        didSet {
            if isGrabbed {
                boxRef?.isHidden = true
            } else {
                boxRef?.isHidden = false
            }
        }
    }
    
    // Keep track of current action to avoid restarting the animation
    private var currentState: PlayerTextureState = .idle
    private var currentActionKey = "PlayerAnimation"
    
    init(playerEra: PlayerEra) {
        self.playerEra = playerEra // Initialize with the player era

        // Start with the idle texture for the given era
        let texture = SKTexture(imageNamed: "\(playerEra == .present ? "player-idle-present" : "player-idle-future")-1")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.zPosition = 1
        // Set the default visual scale of the sprite
        self.setScale(5) // Adjust as needed
        
        setupPhysicsBody()
        setupBindings()
        
        // Start with the idle animation
        changeState(to: .idle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPhysicsBody() {
        // Use the original size for the physics body
        let bodySize = self.size // Original size before scaling
        
        self.physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategories.player
        self.physicsBody?.contactTestBitMask = PhysicsCategories.ground | PhysicsCategories.box
        self.physicsBody?.collisionBitMask = PhysicsCategories.ground | PhysicsCategories.box
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
            self.xScale = -abs(self.xScale)
        case .moveRight:
            isMovingRight = true
            facingRight = true
            self.xScale = abs(self.xScale)
        case .jump:
            if isGrounded { // Ensure player can only jump when grounded
                self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
                isGrounded = false
                changeState(to: .jumping)
            }
            case .grab:
                if boxRef != nil {
                    isGrabbed = true
                }
        default:
            break
        }
    }
    
    func handleKeyRelease(action: GameActions) {
        switch action {
        case .moveLeft:
            isMovingLeft = false
            if isMovingRight {
                facingRight = true
                self.xScale = abs(self.xScale)
            }
        case .moveRight:
            isMovingRight = false
            if isMovingLeft {
                facingRight = false
                self.xScale = -abs(self.xScale)
            }
            case .grab:
                if isGrabbed {
                    isGrabbed = false
                }
        default:
            break
        }
    }
    
    // Update player position and animation based on movement direction
    func update(deltaTime: TimeInterval) {
        var desiredVelocity: CGFloat = 0.0
        
        if isMovingLeft && !isMovingRight {
            desiredVelocity = -moveSpeed
        } else if isMovingRight && !isMovingLeft {
            desiredVelocity = moveSpeed
        } else {
            desiredVelocity = 0.0
        }
        
        // Apply velocity
        self.physicsBody?.velocity.dx = desiredVelocity
        
        // Ground detection using contact count
        // isGrounded is updated in didBegin and didEnd methods
        
        // Determine the appropriate state
        if !isGrounded {
            changeState(to: .jumping)
        } else if desiredVelocity != 0 {
            changeState(to: .running)
        } else {
            changeState(to: .idle)
        }
    }
    
    // Change the player's animation state
    private func changeState(to newState: PlayerTextureState) {
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
    
    
    // Handle landing after a jump
    func didBegin(_ contact: SKPhysicsContact) {
        let otherBody = (contact.bodyA.categoryBitMask == PhysicsCategories.player) ? contact.bodyB : contact.bodyA
        let otherCategory = otherBody.categoryBitMask
        
        if otherCategory == PhysicsCategories.ground || otherCategory == PhysicsCategories.box {
            groundContactCount += 1
            isGrounded = true
        }
    }
    
    // Handle leaving the ground (e.g., jumping off a platform)
    func didEnd(_ contact: SKPhysicsContact) {
        let otherBody = (contact.bodyA.categoryBitMask == PhysicsCategories.player) ? contact.bodyB : contact.bodyA
        let otherCategory = otherBody.categoryBitMask
        
        if otherCategory == PhysicsCategories.ground || otherCategory == PhysicsCategories.box {
            groundContactCount = max(groundContactCount - 1, 0)
            if groundContactCount == 0 {
                isGrounded = false
            }
        }
        
    }
}
