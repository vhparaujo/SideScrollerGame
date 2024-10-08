//
//  SpawnPointNode.swift
//  SideScrollerGame
//
//  Created by Eduardo on 07/10/24.
//

import SpriteKit

class SpawnPointNode: SKSpriteNode {
    
    init(size: CGSize, position: CGPoint) {
        super.init(texture: nil, color: .blue, size: size)
        
        self.position = position
        self.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
