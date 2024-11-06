//
//  Ladder.swift
//  SideScrollerGame
//
//  Created by Victor Hugo Pacheco Araujo on 16/10/24.
//

import SpriteKit

class Ladder: SKNode {
    
    var size: CGSize
    
    init(size: CGSize) {
        self.size = size
        
        super.init()
        self.name = "Ladder"
        self.zPosition = 1
        
        setupLadder(height: self.size.height)
        setupPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategories.ladder
    }
    
    private func setupLadder(height: CGFloat) {
        // Carregar as texturas dos assets
        let topTexture = SKTexture(imageNamed: "stairs-future-top")
        let middleTexture = SKTexture(imageNamed: "stairs-future-middle")
        let bottomTexture = SKTexture(imageNamed: "stairs-future-bottom")
        
        // Alturas dos segmentos
        let middleHeight = middleTexture.size().height * 0.3
        
        // Adicionar o topo da escada
        let topNode = SKSpriteNode(texture: topTexture)
        topNode.setScale(0.3)
        let topHeight = topNode.size.height
        topNode.position = CGPoint(x: 0, y: height / 2 - topHeight / 2)
        addChild(topNode)
        
        // Adicionar a base da escada
        let bottomNode = SKSpriteNode(texture: bottomTexture)
        bottomNode.setScale(0.3)
        let bottomHeight = bottomNode.size.height
        bottomNode.position = CGPoint(x: 0, y: -height / 2 + bottomHeight / 2)
        addChild(bottomNode)
        
        // Calcular a área disponível para o trecho intermediário
        let remainingHeight = height - (topHeight + bottomHeight)
        var loopTimes = remainingHeight / middleHeight
        
        let topPositionY: CGFloat = topNode.position.y
        var positionY: CGFloat = topPositionY - (topHeight / 2) - (middleHeight / 2)
    
        while loopTimes >= 0 {
            let middleNode = SKSpriteNode(texture: middleTexture)
            middleNode.position = CGPoint(x: 0, y: positionY)
            middleNode.setScale(0.3)
            addChild(middleNode)
            loopTimes -= 1.0
            positionY = middleNode.position.y - middleHeight
        }

    }
}
