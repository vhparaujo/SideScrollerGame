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
    
    init(texture: SKTexture, size: CGSize) {
        super.init(texture: texture, color: .clear, size: size)
        
        self.anchorPoint = .zero
        self.zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
