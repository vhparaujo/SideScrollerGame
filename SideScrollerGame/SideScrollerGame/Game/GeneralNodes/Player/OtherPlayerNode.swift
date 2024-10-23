import Foundation
import CoreGraphics
import Combine

class OtherPlayerNode: PlayerNode {
    private var targetPosition: CGPoint?
    private var targetVelocity: CGVector?
    private var interpolationSpeed: CGFloat = 10.0
    private var updateTimer: Timer = .init()
    
    private var lastState: PlayerTextureState = .idle
    
    override init(playerEra: PlayerEra, mpManager: MultiplayerManager) {
        super.init(playerEra: playerEra, mpManager: mpManager)
        
        self.physicsBody?.affectedByGravity = false
        
        self.mpManager = mpManager
        self.physicsBody?.categoryBitMask = PhysicsCategories.otherPlayer

        // Assinar para atualizações de outros jogadores
        setupBindings()
        startPositionUpdateTimer()
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder, playerEra: PlayerEra, mpManager: MultiplayerManager) {
        fatalError("init(coder:playerEra:mpManager:) has not been implemented")
    }
    
    // Recebe atualizações de posição e estado do MultiplayerManager
    internal func setupBindings() {
        mpManager.otherPlayerInfo
            .sink { [weak self] (playerInfo: PlayerInfo?) in
                guard let self = self, let playerInfo = playerInfo else { return }
                self.playerInfo = playerInfo
                
                // Atualize a textura com base no estado do jogador
                self.updateTexture(for: playerInfo.textureState)
            }
            .store(in: &cancellables)
    }
    
    // Função para iniciar o timer de atualização de posição
    private func startPositionUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            if let self = self {
                self.position = self.playerInfo.position
            }
        }
    }
    
    override func update(deltaTime: TimeInterval) {
        // Atualize a posição do jogador
        if self.position != mpManager.otherPlayerInfo.value?.position {
            self.position = mpManager.otherPlayerInfo.value?.position ?? .zero
        }
       
       

        // Certifique-se de que a textura está sempre atualizada com base no estado
        updateTexture(for: playerInfo.textureState)
    }
    
    // Função para atualizar a textura com base no estado do jogador
    func updateTexture(for state: PlayerTextureState) {
        switch state {
        case .running:
            if lastState != state{
                changeState(to: .running)
                self.lastState = state
            }
        case .idle:
            if lastState != state{
                changeState(to: .idle)
                self.lastState = state
            }
        case .jumping:
            if lastState != state{
                changeState(to: .jumping)
                self.lastState = state
            }
        case .climbing:
            if lastState != state{
                changeState(to: .climbing)
                self.lastState = state
            }
        case .grabbing:
            changeState(to: .grabbing)
            self.lastState = state
        case .hurt:
            if lastState != state{
                changeState(to: .hurt)
                self.lastState = state
            }
        }
    }
}
