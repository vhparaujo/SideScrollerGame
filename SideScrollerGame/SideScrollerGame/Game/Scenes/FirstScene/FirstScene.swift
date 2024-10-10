//
//  FisstScene.swift
//  SideScrollerGame
//
//  Created by Eduardo on 03/10/24.
//

import SpriteKit

class FirstScene: SKScene, SKPhysicsContactDelegate {
    var playerEra: PlayerEra!
    
    var mpManager: MultiplayerManager
    
    private var playerNode: PlayerNode!
    private var otherPlayer: OtherPlayerNode!
    
    private var spawnPoint: SpawnPointNode!
    private var spawnPoint2: SpawnPointNode!
    
    private var parallaxBackground: ParallaxBackground!
    var cameraNode: SKCameraNode = SKCameraNode()
    
    var previousCameraXPosition: CGFloat = 0.0
    var platform: PlatformNode!
    
    var tileMapWidth: CGFloat = 0.0
    
    private var lastUpdateTime: TimeInterval = 0 // Declare and initialize lastUpdateTime
    
    init(size: CGSize, mpManager: MultiplayerManager, playerEra: PlayerEra) {
        self.playerEra = playerEra
        self.mpManager = mpManager
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.mpManager = MultiplayerManager()
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        self.name = "firstScene"
        self.backgroundColor = .clear
        
        physicsWorld.contactDelegate = self
        
        addPlayer()
        addOtherPlayer()
        setupBackground()
        setupCamera()
        
        addGeneralBoxes()
        addFutureBoxes()
        addSpawnPoint()
        
        let mapBuilder = MapBuilder(scene: self)
        mapBuilder.embedScene(fromFileNamed: MapTexture.firstScene.textures(for: playerEra))
        tileMapWidth = mapBuilder.tileMapWidth
        
    }
    
    override func keyUp(with event: NSEvent) {
        
    }
    
    override func keyDown(with event: NSEvent) {
        
    }
    
    func addBox(position: CGPoint, id: UUID = .init(), alreadyHadBox: Bool = false){
        let newBox = BoxNode()
        newBox.position = position
        newBox.id = id
        newBox.name = "\(newBox.id)"
        addChild(newBox)
        
        if !alreadyHadBox{
//            mpManager.firstSceneBoxes.append(.init(position: newBox.position, id: newBox.id))
        }
    }
    
    func addFutureBoxes() {
        if playerEra == .future{
            addBox(position: CGPoint(x: size.width * 3.5 + 150, y: size.height / 2 + 250))
            addBox(position: CGPoint(x: size.width * 3.5 + 500, y: size.height / 2 + 250))
        }
    }
    
    func addGeneralBoxes() {
        addBox(position: CGPoint(x: size.width / 3 - 100, y: size.height / 2))
        addBox(position: CGPoint(x: size.width + 550, y: size.height / 2))
        addBox(position: CGPoint(x: size.width * 5 + 700, y: size.height / 2))
    }
    
    func addSpawnPoint() {
        spawnPoint = SpawnPointNode(size: CGSize(width: 50, height: 50), position: CGPoint(x: size.width / 2, y: size.height / 8))
        addChild(spawnPoint)
        
        spawnPoint2 = SpawnPointNode(size: CGSize(width: 50, height: 50), position: CGPoint(x: size.width * 3, y: size.height / 2 + 200))
        addChild(spawnPoint2)
    }
    
    func addPlayer() {
        playerNode = PlayerNode(playerEra: playerEra, mpManager: mpManager)
        playerNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(playerNode)
    }
    
    func addOtherPlayer() {
        
        var otherPlayerEra: PlayerEra
        
        if playerEra == .present {
            otherPlayerEra = .future
        } else {
            otherPlayerEra = .present
        }
        
        guard otherPlayer == nil else { return }
        otherPlayer = OtherPlayerNode(playerEra: otherPlayerEra, mpManager: mpManager)
        otherPlayer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(otherPlayer)
        
    }
    
    // Update method to control player movement
    override func update(_ currentTime: TimeInterval) {
        self.cameraAndBackgroundUpdate()
        
        // Calculate deltaTime if needed
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Update the player
        playerNode.update(deltaTime: deltaTime)
        
        // Update the other player if it exists
        otherPlayer.update(deltaTime: deltaTime)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        playerNode.didBegin(contact)
        
        // Determine which body is the player and which is the box
        let otherBody = (contact.bodyA.categoryBitMask == PhysicsCategories.player) ? contact.bodyB : contact.bodyA
        let otherCategory = otherBody.categoryBitMask
        
        if otherCategory == PhysicsCategories.box {
            
            // Cast the other node to BoxNode to get the specific box
            if let boxNode = otherBody.node as? BoxNode {
                playerNode.boxRef = boxNode
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        playerNode.didEnd(contact)
        
        let otherBody = (contact.bodyA.categoryBitMask == PhysicsCategories.player) ? contact.bodyB : contact.bodyA
        let otherCategory = otherBody.categoryBitMask
        
        if otherCategory == PhysicsCategories.box {
            if let boxNode = otherBody.node as? BoxNode {
                // Only set boxRef to nil if it's the same box the player was interacting with
                if playerNode.boxRef === boxNode {
                    playerNode.boxRef = nil
                }
            }
        }
    }
    
    //    func cameraAndBackgroundUpdate() {
    //        cameraNode.position.x = playerNode.position.x
    //        let cameraMovementX = cameraNode.position.x - previousCameraXPosition
    //        self.parallaxBackground.moveParallaxBackground(cameraMovementX: cameraMovementX)
    //        self.parallaxBackground.paginateBackgroundLayers(cameraNode: cameraNode)
    //        self.previousCameraXPosition = cameraNode.position.x
    //
    //    }
    
    
    func cameraAndBackgroundUpdate() {
        // Calculate the visible size based on the camera's scale
        let visibleSize = CGSize(width: self.size.width / cameraNode.xScale, height: self.size.height / cameraNode.yScale)
        
        // Set the camera's X position to follow the player
        var newCameraX = playerNode.position.x
        
        // Calculate the map boundaries
        let leftBoundary = visibleSize.width / 2
        let rightBoundary = max(0, tileMapWidth - visibleSize.width / 2)
        
        // Clamp the camera's X position between the boundaries
        newCameraX = max(leftBoundary, min(newCameraX, rightBoundary))
        
        cameraNode.position.x = newCameraX
        let cameraMovementX = cameraNode.position.x - previousCameraXPosition
        self.parallaxBackground.moveParallaxBackground(cameraMovementX: cameraMovementX)
        self.parallaxBackground.paginateBackgroundLayers(cameraNode: cameraNode)
        self.previousCameraXPosition = cameraNode.position.x
        
        // Follow the player in Y direction (optional if you want vertical camera movement)
        let targetY = playerNode.position.y
        let currentY = cameraNode.position.y
        let interpolationSpeed: CGFloat = 0.1
        let deltaY = targetY - currentY
        let newY = currentY + deltaY * interpolationSpeed
        cameraNode.position.y = newY
    }
    
    
    
    func setupCamera() {
        self.cameraNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(self.cameraNode)
        self.camera = cameraNode
        self.previousCameraXPosition = cameraNode.position.x
    }
    
    func setupBackground() {
        self.parallaxBackground = ParallaxBackground(screenSize: self.size, background: BackgroundTexture.firstScene.textures(for: playerEra))
        
        self.addChild(parallaxBackground!)
    }
    
}
