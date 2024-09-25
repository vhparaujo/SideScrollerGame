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
    private var parallaxBackground: ParallaxBackground!
    var cameraNode: SKCameraNode = SKCameraNode()
    private let box = BoxNode()
    private let box2 = BoxNode()
    
    var previousCameraXPosition: CGFloat = 0.0
    
    override func didMove(to view: SKView) {
        self.name = "DesertScene"
        self.backgroundColor = .black
        
        physicsWorld.contactDelegate = self
        
        setupBackground()
        playerNode = PlayerNode(playerEra: .present)
        playerNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(playerNode)
        
        setupCamera()
        
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
        
        cameraNode.position.x = playerNode.position.x
        
        let cameraMovementX = cameraNode.position.x - previousCameraXPosition
        
        self.parallaxBackground.moveParallaxBackground(cameraMovementX: cameraMovementX)
        self.parallaxBackground.paginateBackgroundLayers(cameraNode: cameraNode)
        self.previousCameraXPosition = cameraNode.position.x
        print(playerNode.position.x)
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
    
    func setupCamera() {
        self.cameraNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(self.cameraNode)
        self.camera = cameraNode
        self.previousCameraXPosition = cameraNode.position.x
    }

    func setupBackground() {
        let images: [String] = ["close-trees", "mid-trees", "far-trees", "background"]
        self.parallaxBackground = ParallaxBackground(screenSize: self.size, backgroundImages: images)
        
        self.addChild(parallaxBackground!)
    }
}
