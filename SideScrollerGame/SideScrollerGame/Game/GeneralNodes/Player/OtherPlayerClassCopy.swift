import SpriteKit
import Combine
import SwiftUI

class OtherPlayerNode: SKSpriteNode {
    
    var cancellables = Set<AnyCancellable>()
    let controller = GameControllerManager.shared
    let playerEra: PlayerEra
    var mpManager: MultiplayerManager
    
    // Movement properties
    let moveSpeed: CGFloat = 500.0
    let jumpImpulse: CGFloat = 7700.0
    
//    var playerInfo = PlayerInfo(
//        textureState: .idleR,
//        facingRight: true,
//        action: false,
//        isDying: false,
//        position: .zero,
//        readyToNextScene: false
//    )
    var playerInfo: PlayerInfo?
    
    private var isGrounded = false

    let currentActionKey = "PlayerAnimation"
    
    private var updateTimer: Timer = .init()
    
    private var lastState: PlayerTextureState = .idleR
    
    
    init(playerEra: PlayerEra, mpManager: MultiplayerManager = .shared) {
        
      
        if let info = mpManager.otherPlayerInfo.value{
               self.playerInfo = info
           }
      
        self.playerEra = playerEra
        self.mpManager = mpManager
        
        let textureName = playerEra == .present ? "player-present-walk-right-1" : "player-future-walk-right-1"
        let texture = SKTexture(imageNamed: textureName)
        
        super.init(texture: texture, color: .clear, size: texture.size())
        self.zPosition = 1
        self.setScale(0.25)
        
        self.physicsBody?.categoryBitMask = PhysicsCategories.otherPlayer
        self.physicsBody?.affectedByGravity = false

        
        setupBindings()
        changeState(to: .idleR)
        startPositionUpdateTimer()

    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
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
    
     func update(deltaTime: TimeInterval) {
        // Atualize a posição do jogador
        if self.position != mpManager.otherPlayerInfo.value?.position {
            self.position = mpManager.otherPlayerInfo.value?.position ?? .zero
        }
       
       

        // Certifique-se de que a textura está sempre atualizada com base no estado
        updateTexture(for: playerInfo.textureState)
    }
  
    
    private func handleJump() {
        if !playerInfo.action && isGrounded {
            guard let dyVelocity = physicsBody?.velocity.dy else { return }
            if dyVelocity <= 0.0 {
                physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
                isGrounded = false
            }
            changeState(to: .jumpingL)

        }
    }
    
    func updateTexture(for state: PlayerTextureState) {
        switch state {
        case .runningR:
            if lastState != state{
                changeState(to: .runningR)
                self.lastState = state
            }
        case .runningL:
            if lastState != state{
                changeState(to: .runningR)
                self.lastState = state
            }
        case .idleR:
            if lastState != state{
                changeState(to: .idleR)
                self.lastState = state
            }
        case .idleL:
            if lastState != state{
                changeState(to: .idleL)
                self.lastState = state
            }
        case .jumpingL:
            if lastState != state{
                changeState(to: .jumpingL)
                self.lastState = state
            }
        case .jumpingR:
            if lastState != state{
                changeState(to: .jumpingR)
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
}
