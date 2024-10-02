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
    private var moveSpeed: CGFloat = 250.0
    let jumpImpulse: CGFloat = 500.0 // Impulse applied to the player when jumping
    
    
    private var isMovingLeft = false
    private var isMovingRight = false
    private var isGrounded = true
    private var isDying = false
    private var groundContactCount = 0 // Tracks number of ground contacts
    
    private var facingRight = true // Tracks the orientation
    
    private var currentPlatform: PlatformNode?
    
    //Box movement
    var boxRef: BoxNode?
    private var isGrabbed = false
    private var boxOffset: CGFloat = 0.0
    
    
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
        self.setScale(4) // Adjust as needed
        
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
                if isGrounded, !isGrabbed {
                    self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
                    isGrounded = false
                    changeState(to: .jumping)
                }
            case .grab:
                if isGrounded {
                    if let box = boxRef {
                        isGrabbed = true
                        box.isGrabbed = true
                        box.enableMovement()
                        // Capture the initial offset between the box and the player
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
    
    func triggerDeath() {
        // Alterar estado para "morte" para evitar outras ações
        self.isDying = true

        // Remover todas as ações anteriores
            self.removeAllActions()
            
            // Desativar a física do jogador para evitar movimentação durante a animação
            self.physicsBody?.isDynamic = false
            
            // **Parte 1: Salto para cima**
            let jumpUp = SKAction.moveBy(x: 0, y: 300, duration: 0.3) // O personagem pula para fora da tela
        let scaleDown = SKAction.scale(to: 7, duration: 0.3)    // O personagem encolhe enquanto sobe
            
            // **Parte 2: Queda rápida**
        let fallDown = SKAction.moveBy(x: 0, y: -1000, duration: 0.8) // O personagem cai rapidamente
        let scaleUp = SKAction.scale(to: 5, duration: 0.8)          // O personagem desaparece gradualmente durante a queda

            // **Animação de texturas durante o salto e queda**
            let deathTextures = PlayerTextureState.hurt.textures(for: playerEra)
            let deathAnimation = SKAction.animate(with: deathTextures, timePerFrame: 0.1)
            
            // **Repetir a animação até o final da sequência de morte**
            let repeatDeathAnimation = SKAction.repeatForever(deathAnimation)
            
            // **Combinar a animação com o movimento de salto e queda**
        let jumpAndAnimate = SKAction.group([SKAction.sequence([jumpUp, scaleDown, fallDown, scaleUp]), repeatDeathAnimation, SKAction.run { [weak self] in
            self?.isDying = false
            
        }])
            
            // Executar a sequência de animação e movimento
            let deathSequence = SKAction.sequence([jumpAndAnimate, SKAction.removeFromParent()])
            
            // Rodar a sequência de morte
            self.run(deathSequence)
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
        } else if isDying {
            changeState(to: .hurt)
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
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let otherBody = (contact.bodyA.categoryBitMask == PhysicsCategories.player) ? contact.bodyB : contact.bodyA
        let otherCategory = otherBody.categoryBitMask
        
        if otherCategory == PhysicsCategories.fatal {
            triggerDeath()
        }

        if otherCategory == PhysicsCategories.ground || otherCategory == PhysicsCategories.box || otherCategory == PhysicsCategories.platform {
            groundContactCount += 1
            isGrounded = true

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

}
