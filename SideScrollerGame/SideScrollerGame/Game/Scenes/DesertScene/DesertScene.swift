//
//  DesertScene.swift
//  SideScrollerGame
//
//  Created by Eduardo on 19/09/24.
//

import SpriteKit
import SwiftUICore

class DesertScene: SKScene, SKPhysicsContactDelegate {
    
    let ground = SKSpriteNode(color: .clear, size: CGSize(width: 10000, height: 50))
    
    private var playerNode: PlayerNode!
    private let box = BoxNode()
    private let box2 = BoxNode()


    override func didMove(to view: SKView) {
        self.name = "DesertScene"
        self.backgroundColor = .black
        
        physicsWorld.contactDelegate = self
        
        
        
        playerNode = PlayerNode(playerEra: .present)
        playerNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(playerNode)
        
        // Add a box to the scene
        box.position = CGPoint(x: 300, y: 100) // Adjust as needed
        addChild(box)        // Add a box to the scene
        box2.position = CGPoint(x: 300, y: 100) // Adjust as needed
        addChild(box2)
        
        setupPhysics()
        
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPhysics() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategories.ground
        physicsBody?.contactTestBitMask = PhysicsCategories.player
        physicsBody?.collisionBitMask = PhysicsCategories.player
    }
    
    // Update method to control player movement
    override func update(_ currentTime: TimeInterval) {
        playerNode.update(deltaTime: currentTime)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {

        playerNode.didBegin(contact)
        
        let otherBody = (contact.bodyA.categoryBitMask == PhysicsCategories.player) ? contact.bodyB : contact.bodyA
        let otherCategory = otherBody.categoryBitMask
        
        if  otherCategory == PhysicsCategories.box {
            playerNode.boxRef = box
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        playerNode.didEnd(contact)
        
        let otherBody = (contact.bodyA.categoryBitMask == PhysicsCategories.player) ? contact.bodyB : contact.bodyA
        let otherCategory = otherBody.categoryBitMask
        
        if  otherCategory == PhysicsCategories.box {
            playerNode.boxRef = nil
        }
    }
}
