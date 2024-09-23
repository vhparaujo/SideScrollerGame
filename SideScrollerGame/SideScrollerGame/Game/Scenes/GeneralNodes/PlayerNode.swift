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
    
    private var controller: GameController
    
    // Define movement properties for the player
    private var moveSpeed: CGFloat = 200.0
    private var isJumping = false
    private var isMovingLeft = false
    private var isMovingRight = false
    
    init(texture: SKTexture, size: CGSize, controller: GameController) {
        self.controller = controller
        super.init(texture: texture, color: .clear, size: size)
        
        self.anchorPoint = .zero
        self.zPosition = 1
        
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBindings() {
        
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
    
    func handleKeyPress(action: GameActions) {
        switch action {
            case .moveLeft:
                break
            case .moveRight:
                break
            case .jump:
                break
            case .climb:
                break
            case .grab:
                break
        }
    }
    
    func handleKeyRelease(action : GameActions) {
        switch action {
            case .grab:
                break
            default:
                break
        }
    }
}
