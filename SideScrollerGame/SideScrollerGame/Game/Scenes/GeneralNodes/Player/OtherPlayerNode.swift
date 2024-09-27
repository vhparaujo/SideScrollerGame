import Foundation
import CoreGraphics
import Combine

class OtherPlayerNode: PlayerNode {
    private var targetPosition: CGPoint?
    private var targetVelocity: CGVector?
    private var interpolationSpeed: CGFloat = 10.0 // Velocidade de interpolação

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
                
                // Atualizar o alvo de posição e velocidade recebida
                self.targetPosition = playerInfo.position
                self.targetVelocity = playerInfo.velocity
            }
            .store(in: &cancellables)
    }

    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)
        
        print(position)
        
        // Interpolar para a nova posição recebida se disponível
        if let targetPosition = targetPosition {
            let dx = targetPosition.x - position.x
            let dy = targetPosition.y - position.y
            position.x += dx * interpolationSpeed * CGFloat(deltaTime)
            position.y += dy * interpolationSpeed * CGFloat(deltaTime)
        }
        
        // Aplicar a nova velocidade recebida, se disponível
        if let targetVelocity = targetVelocity {
            physicsBody?.velocity = targetVelocity
        }
    }
}
