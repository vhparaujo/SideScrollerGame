import Foundation
import CoreGraphics
import Combine

class OtherPlayerNode: PlayerNode {
    private var targetPosition: CGPoint?
    private var targetVelocity: CGVector?
    private var interpolationSpeed: CGFloat = 10.0
    private var otherPlayerInfo: PlayerInfo?

    override init(playerEra: PlayerEra, mpManager: MultiplayerManager) {
        
        super.init(playerEra: playerEra, mpManager: mpManager)
        
        self.mpManager = mpManager
        
        self.physicsBody?.categoryBitMask = PhysicsCategories.otherPlayer

        // Assinar para atualizações de outros jogadores
        setupBindings()
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Recebe atualizações de posição e estado do MultiplayerManager
    internal override func setupBindings() {
        mpManager.otherPlayerInfo
            .sink { [weak self] (playerInfo: PlayerInfo?) in
                guard let self = self, let playerInfo = playerInfo else { return }
                
//                self.targetPosition = playerInfo.position
//                self.targetVelocity = playerInfo.velocity
                self.otherPlayerInfo = playerInfo
                
                self.isMovingLeft = playerInfo.isMovingLeft
                self.isMovingRight = playerInfo.isMovingRight
                self.facingRight = playerInfo.facingRight
                self.isGrabbed = playerInfo.isGrabbed
                self.currentState = playerInfo.state
            }
            .store(in: &cancellables)
    }

//    override func update(deltaTime: TimeInterval) {
//        super.update(deltaTime: deltaTime)
//      
//        
//        
//
////        if let targetPosition = targetPosition {
////            let dx = targetPosition.x - position.x
////            let dy = targetPosition.y - position.y
////            position.x += dx * interpolationSpeed * CGFloat(deltaTime)
////            position.y += dy * interpolationSpeed * CGFloat(deltaTime)
////        }
//        
//        // Aplicar a nova velocidade recebida, se disponível
//        if let targetVelocity = targetVelocity {
//            physicsBody?.velocity = targetVelocity
//        }
//    }
    
    override func update(deltaTime: TimeInterval) {
        

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
}
