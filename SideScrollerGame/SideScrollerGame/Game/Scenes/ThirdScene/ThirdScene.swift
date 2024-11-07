//
//  ThirdScene.swift
//  SideScrollerGame
//
//  Created by Victor Hugo Pacheco Araujo on 05/11/24.
//

import SpriteKit

class ThirdScene: SKScene, SKPhysicsContactDelegate {
    var playerEra: PlayerEra!
    
    var mpManager: MultiplayerManager
    
    var playerNode: PlayerNode!
    var otherPlayer: OtherPlayerNode!
    
    private var parallaxBackground: ParallaxBackground!
    var cameraNode: SKCameraNode = SKCameraNode()
    
    var previousCameraXPosition: CGFloat = 0.0
    
    var tileMapWidth: CGFloat = 0.0
    var tileMapHeight: CGFloat = 0.0
    
    var fadeNode: SKSpriteNode!
    
    private var lastUpdateTime: TimeInterval = 0
    
    var thirdSceneGeneralBoxes: [BoxNode] = []
    
    let cameraNode2 = SKCameraNode()
    let visionField = SKShapeNode(rectOf: CGSize(width: 300, height: 200))
    
    init(size: CGSize, mpManager: MultiplayerManager = .shared, playerEra: PlayerEra) {
        self.playerEra = playerEra
        self.mpManager = mpManager
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.mpManager = MultiplayerManager()
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        self.name = "thirdScene"
        self.backgroundColor = .clear
        
        physicsWorld.contactDelegate = self
        
        let mapBuilder = MapBuilder(scene: self)
        mapBuilder.embedScene(fromFileNamed: MapTexture.thirdScene.textures(for: playerEra))
        tileMapWidth = mapBuilder.tileMapWidth
        tileMapHeight = mapBuilder.tileMapHeight
        
        setupBackground()
        setupCamera()
        
        visionField.fillColor = .clear
        visionField.strokeColor = .red
        visionField.position = CGPoint(x: 0, y: 0) // Posição do campo de visão em relação à câmera
        cameraNode2.addChild(visionField)
        
        self.addChild(cameraNode2)
    }
    
    override func keyUp(with event: NSEvent) {}
    
    override func keyDown(with event: NSEvent) {}
    
    func addBoxWithoutSendingToOthers(position: CGPoint, id: UUID = .init()){
        let newBox = BoxNode()
        newBox.position = position
        newBox.id = id
        newBox.name = "\(newBox.id)"
        addChild(newBox)
        thirdSceneGeneralBoxes.append(newBox)
    }
    
    func addBoxesToArray(){
        if playerNode.bringBoxToPresent && playerEra == .future, let box = playerNode.boxRef{
            if !self.thirdSceneGeneralBoxes.contains(box){
                self.thirdSceneGeneralBoxes.append(box)
                mpManager.sendInfoToOtherPlayers(content: .init(position: box.position, id: box.id, isGrabbed: false))
                playerNode.bringBoxToPresent = false
            }
        }
    }
    
    // Update method to control player movement
    override func update(_ currentTime: TimeInterval) {
        self.cameraAndBackgroundUpdate()
        
        self.addBoxesToArray()
        
        self.updateBoxes()
        
        // Calculate deltaTime if needed
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        for box in thirdSceneGeneralBoxes {
            box.update(deltaTime: deltaTime)
        }
        
        // Update the player
        playerNode.update(deltaTime: deltaTime)
        
        // Update the other player if it exists
        otherPlayer.update(deltaTime: deltaTime)
        
        cameraNode2.zRotation += 0.01 // Ajuste este valor para controlar a velocidade da rotação
        
        let visionFieldFrame = CGRect(x: -150, y: -100, width: 300, height: 200) // Área do campo de visão
        
        let rotatedVisionFieldPosition = CGPoint(
            x: 0,
            y: cameraNode2.position.y + 100 * sin(cameraNode2.zRotation)
        )
        
        visionField.position = rotatedVisionFieldPosition
        
        if visionFieldFrame.contains(playerNode.position) {
            // Executar ação quando o jogador estiver no campo de visão
            print("Jogador detectado!")
            // Aqui você pode adicionar a ação que deseja executar
        }
    }
    
    func updateBoxes(){
        if playerEra == .present {
            for box in mpManager.scenesGeneralBoxes {
                if !self.children.contains(where: { node in
                    "\(box.value.id)" == node.name
                }){
                    addBoxWithoutSendingToOthers(position: box.value.position, id: box.value.id)
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        playerNode.didBegin(contact)
        
        // Determine which body is the player and which is the box
        let otherBody = (contact.bodyA.categoryBitMask == PhysicsCategories.player) ? contact.bodyB : contact.bodyA
        let otherCategory = otherBody.categoryBitMask
    
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        playerNode.didEnd(contact)
        
        let otherBody = (contact.bodyA.categoryBitMask == PhysicsCategories.player) ? contact.bodyB : contact.bodyA
        let otherCategory = otherBody.categoryBitMask
        
        let boxBody = (contact.bodyA.categoryBitMask == PhysicsCategories.box) ? contact.bodyB : contact.bodyA
        let otherBox = boxBody.categoryBitMask
        
        if otherBox == PhysicsCategories.box {
            if let boxNode = otherBody.node as? BoxNode {
                boxNode.disableMovement()
            }
        }
        
    }
    
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
        self.parallaxBackground = ParallaxBackground(mapHeight: self.tileMapHeight, screenSize: self.size, background: BackgroundTexture.thirdScene.textures(for: playerEra))
        
        parallaxBackground.zPosition = -10
        self.addChild(parallaxBackground!)
    }
}
