import Foundation
import CoreGraphics
import Combine

class OtherPlayerNode: PlayerNode {
    private var targetPosition: CGPoint?
    private var targetVelocity: CGVector?
    private var interpolationSpeed: CGFloat = 10.0
    private var updateTimer: Timer = .init()
    
    override init(playerEra: PlayerEra, mpManager: MultiplayerManager) {
        
        super.init(playerEra: playerEra, mpManager: mpManager)
        
        self.mpManager = mpManager
        
        self.physicsBody?.categoryBitMask = PhysicsCategories.otherPlayer

        // Assinar para atualizações de outros jogadores
        setupBindings()
        
        startPositionUpdateTimer()

    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Recebe atualizações de posição e estado do MultiplayerManager
    internal override func setupBindings() {
        mpManager.otherPlayerInfo
            .sink { [weak self] (playerInfo: PlayerInfo?) in
                guard let self = self, let playerInfo = playerInfo else { return }
                self.playerInfo = playerInfo
                
            }
            .store(in: &cancellables)
    }
    
    // Função para iniciar o timer de atualização
        private func startPositionUpdateTimer() {
            updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
//                self.position = playerInfo.position
                
                if let self = self {
                    self.position = self.playerInfo.position
                    print(self.position)
                    print("player info:\(self.playerInfo)")
                }
            }
        }
    
    
    
    
    override func update(deltaTime: TimeInterval) {
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
        } else {
            changeState(to: .idle)
        }
    }
}
