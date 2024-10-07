//
//  SpawnPointNode.swift
//  SideScrollerGame
//
//  Created by Eduardo on 07/10/24.
//

import SpriteKit

class SpawnPointNode: SKSpriteNode {
    
    init(size: CGSize, position: CGPoint) {
        super.init(texture: nil, color: .red, size: size)
        
        self.position = position
        
        self.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
