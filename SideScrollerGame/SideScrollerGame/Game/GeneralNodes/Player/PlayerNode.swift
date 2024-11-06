import SpriteKit
import Combine
import SwiftUI

class PlayerNode: SKSpriteNode {
    
    var cancellables = Set<AnyCancellable>()
    let controller = GameControllerManager.shared
    let playerEra: PlayerEra
    var mpManager: MultiplayerManager
    
    // Movement properties
    let moveSpeed: CGFloat = 500.0
    let jumpImpulse: CGFloat = 7700.0
    
    var playerInfo = PlayerInfo(
        textureState: .idleR,
        facingRight: true,
        action: false,
        isDying: false,
        position: .zero,
        readyToNextScene: false
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
    
    init(playerEra: PlayerEra, mpManager: MultiplayerManager = .shared) {
        self.playerEra = playerEra
        self.mpManager = mpManager
        
        let textureName = playerEra == .present ? "player-present-walk-right-1" : "player-future-walk-right-1"
        let texture = SKTexture(imageNamed: textureName)
        
        super.init(texture: texture, color: .clear, size: texture.size())
        self.zPosition = 1
        self.setScale(0.25)
        
        setupPhysicsBody()
        setupBindings()
        changeState(to: .idleR)
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
        physicsBody?.contactTestBitMask = PhysicsCategories.ground | PhysicsCategories.box | PhysicsCategories.wall | PhysicsCategories.ladder | PhysicsCategories.fan | PhysicsCategories.buttonDoor | PhysicsCategories.fanBase
        physicsBody?.collisionBitMask = PhysicsCategories.ground | PhysicsCategories.box | PhysicsCategories.platform | PhysicsCategories.wall | PhysicsCategories.fanBase
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
                  if !isJumping {
                    isJumping = true
                    handleJump()
                }
            case .action:
                handleActionKeyPress()
            case .bringToPresent:
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
            playerInfo.facingRight = false
            case .moveRight:
                isMovingRight = false
            playerInfo.facingRight = true
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
        
        if let buttons = self.scene?.childNode(withName: "ButtonsNode") as? ButtonsNode {
            for child in buttons.children {
                if let buttonNode = child as? ButtonNode {
                    if buttonNode.intersects(self) {
                        if buttonNode.name == "button-one" {
                            buttonNode.buttonPressed.toggle()
                            break
                        }
                        if buttonNode.name == "button-two" {
                            buttonNode.buttonPressed.toggle()
                            break
                        }
                        if buttonNode.name == "button-three" {
                            buttonNode.buttonPressed.toggle()
                            break
                        }
                    }
                }
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
    
    func checkForNearbyObject<T:SKNode>(type: T.Type) -> T? {
 
        let nearbyNodes = self.scene?.children ?? []
        
        for node in nearbyNodes {
            if let object = node as? T {
                
                var pickUpRangeY: CGFloat = object.frame.height * 0.98
                var pickUpRangeX: CGFloat = object.frame.width * 0.9
                
                if ((object.name?.contains("elevator")) != nil){
                    pickUpRangeX = 200 * 0.9
                    pickUpRangeY = 200 * 0.98
                }
                
                let distanceXToObject = object.position.x - self.position.x
                let distanceYToObject = abs(object.position.y - self.position.y)
                
                if abs(distanceXToObject) <= pickUpRangeX, distanceYToObject <= pickUpRangeY {
                    return object
                }
            }
        }
        return nil
    }
    
    func update(deltaTime: TimeInterval) {
        
        if playerInfo.readyToNextScene && mpManager.otherPlayerInfo.value?.readyToNextScene == true{
            transition()
        }
        
        self.boxRef = checkForNearbyObject(type: BoxNode.self)
        self.elevatorRef = checkForNearbyObject(type: ElevatorNode.self)
        
        sendPlayerInfoToOthers()
        handleDeath()
        
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
        } else if !isGrounded && isMovingLeft{
            changeState(to: .jumpingL)
        }else if !isGrounded && isMovingRight{
            changeState(to: .jumpingR)
        }else if desiredVelocity != 0 && isMovingRight{
            changeState(to: .runningR)
        } else if desiredVelocity != 0 && isMovingLeft {
            changeState(to: .runningL)
        }else if playerInfo.facingRight{
            changeState(to: .idleR)
        }else if !playerInfo.facingRight{
            changeState(to: .idleL)
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
        
        //fan logic
        if isOnFan {
            self.physicsBody?.applyForce(CGVector(dx: 0, dy: 400))
            self.physicsBody?.affectedByGravity = false
        } else {
            self.physicsBody?.affectedByGravity = true
        }
    }
    
    private func handleDeath() {
        if playerInfo.isDying {
            self.position = mpManager.spawnpoint
            playerInfo.isDying = false
        }
    }
    
    private func handleJump() {
        if !playerInfo.action && isGrounded {
            guard let dyVelocity = physicsBody?.velocity.dy else { return }
            if dyVelocity <= 0.0 {
                physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
                isGrounded = false
            }
            switch playerInfo.facingRight{
            case true:
                changeState(to: .jumpingR)
            case false:
                changeState(to: .jumpingL)
            }

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
        
        if otherCategory == PhysicsCategories.ground || otherCategory == PhysicsCategories.box || otherCategory == PhysicsCategories.platform {
            
            isJumping = false
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
            GameViewModel.shared.fadeInDeath {
                self.triggerDeath()
            }
        }
        
        if otherCategory == PhysicsCategories.ladder {
            isOnLadder = true
        }
        
        if otherCategory == PhysicsCategories.fan {
            isOnFan = true
        }
        
        if otherCategory == PhysicsCategories.nextScene {
            playerInfo.readyToNextScene = true
            
            if playerInfo.readyToNextScene && mpManager.otherPlayerInfo.value?.readyToNextScene == true{
                
                if SceneValue.scene == .first(playerEra) {
                    transition()
                    
                }else{
                    mpManager.gameFinished = true
                    mpManager.endMatch()
                }
            }
        }
    }
    
    func transition(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let transition = SKTransition.fade(withDuration: 1.0)
            self.scene?.view?.presentScene(SecondScene(size: self.scene?.size ?? .init(width: 1920, height: 1080), playerEra: self.playerEra),transition: transition)
        }

    }
    func didEnd(_ contact: SKPhysicsContact) {
        let otherBody = (contact.bodyA.categoryBitMask == PhysicsCategories.player) ? contact.bodyB : contact.bodyA
        let otherCategory = otherBody.categoryBitMask
        
        if otherCategory == PhysicsCategories.ground || otherCategory == PhysicsCategories.box || otherCategory == PhysicsCategories.platform {
                        
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
