import SpriteKit
import SwiftUICore

class DesertScene: SKScene, SKPhysicsContactDelegate {
    var mpManager: MultiplayerManager
    let ground = SKSpriteNode(color: .clear, size: CGSize(width: 10000, height: 50))
    
    private var playerNode: PlayerNode!
    private var otherPlayer: OtherPlayerNode!
    
    private var parallaxBackground: ParallaxBackground!
    var cameraNode: SKCameraNode = SKCameraNode()
    private let box = BoxNode()
    private let box2 = BoxNode()
    private let fatalBox = SKSpriteNode(color: .clear, size: CGSize(width: 50, height: 50))
    
    var previousCameraXPosition: CGFloat = 0.0
    var platform: PlatformNode!
    
    private var lastUpdateTime: TimeInterval = 0 // Declare and initialize lastUpdateTime

    override func didMove(to view: SKView) {
        self.name = "DesertScene"
        self.backgroundColor = .black
        
        physicsWorld.contactDelegate = self
        
        addPlayer()
        addOtherPlayer()
        setupBackground()
        playerNode = PlayerNode(playerEra: .present, mpManager: mpManager)
        playerNode.position = CGPoint(x: size.width, y: size.height / 2)
        addChild(playerNode)
        
        setupCamera()
        
        // Add a box to the scene
        box.position = CGPoint(x: size.width + 100, y: size.height / 2) // Adjust as needed
        addChild(box)        // Add a box to the scene
        
        fatalBox.position = CGPoint(x: 1200, y: 100)
        fatalBox.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "fatalBox"), size: CGSize(width: 50, height: 50))
        fatalBox.physicsBody?.isDynamic = false
        fatalBox.physicsBody?.categoryBitMask = PhysicsCategories.fatal
        fatalBox.physicsBody?.contactTestBitMask = PhysicsCategories.player
        fatalBox.physicsBody?.collisionBitMask = PhysicsCategories.player
        addChild(fatalBox)
 
        // Define the movement bounds for the platform
        let minX = CGFloat(100)
        let maxX = CGFloat(1000)
        // Initialize and add the platform to the scene
        platform = PlatformNode(minX: minX, maxX: maxX)
        platform.position = CGPoint(x: minX, y: 200) // Set the starting position
        addChild(platform)

                
        // Embed the first scene into the current DesertScene
        if let platformScene = SKScene(fileNamed: "FirstScene") {
            if let tileNode = platformScene.childNode(withName: "FirstSceneTile") as? SKTileMapNode {
                
                tileNode.setScale(5)

                let tileMapWidth = tileNode.mapSize.width * tileNode.xScale

                // Position the tile map at the center of the screen
                tileNode.position = CGPoint(x: tileMapWidth / 2, y: self.size.height / 2)
                tileNode.zPosition = 1

                
                // Remove any existing physics body on the tile map
                tileNode.physicsBody = nil

                // Create a physics layer to hold all the physics bodies
                let physicsLayer = SKNode()
                physicsLayer.position = CGPoint.zero
                addChild(physicsLayer)

                // Iterate over each tile to create individual physics bodies
                for col in 0..<tileNode.numberOfColumns {
                    for row in 0..<tileNode.numberOfRows {
                        // Get the tile definition at this column and row
                        if tileNode.tileDefinition(atColumn: col, row: row) != nil {
                            // Get the tile's position in tileNode's coordinate system
                            let tilePosition = tileNode.centerOfTile(atColumn: col, row: row)
                            // Convert tile position to the scene's coordinate system
                            let tilePositionInScene = tileNode.convert(tilePosition, to: self)
                            // Create a node for the tile's physics body
                            let tilePhysicsNode = SKNode()
                            tilePhysicsNode.position = tilePositionInScene
                            tilePhysicsNode.zPosition = tileNode.zPosition
                            // Adjust the physics body size for the tile's scaling
                            let tileSize = CGSize(width: tileNode.tileSize.width * tileNode.xScale,
                                                  height: tileNode.tileSize.height * tileNode.yScale)
                            // Create the physics body
                            tilePhysicsNode.physicsBody = SKPhysicsBody(rectangleOf: tileSize)
                            tilePhysicsNode.physicsBody?.isDynamic = false
                            // Define physics categories
                            tilePhysicsNode.physicsBody?.categoryBitMask = PhysicsCategories.ground
                            tilePhysicsNode.physicsBody?.contactTestBitMask = PhysicsCategories.player | PhysicsCategories.box
                            tilePhysicsNode.physicsBody?.collisionBitMask = PhysicsCategories.player | PhysicsCategories.box
                            // Add the physics node to the physics layer
                            physicsLayer.addChild(tilePhysicsNode)
                        }
                    }
                }

                tileNode.removeFromParent()
                // Add the tile node to the scene
                addChild(tileNode)
            }
        }
    }
    
    init(size: CGSize, mpManager: MultiplayerManager) {
        self.mpManager = mpManager
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func sceneToNode(scene: SKScene) -> SKSpriteNode {
        // Capture the scene as a texture
        let texture = view?.texture(from: scene)
        
        // Create an SKSpriteNode from the texture
        let spriteNode = SKSpriteNode(texture: texture)
        spriteNode.size = scene.size
        return spriteNode
    }
    
    func setupPhysics() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategories.ground
        physicsBody?.contactTestBitMask = PhysicsCategories.player
        physicsBody?.collisionBitMask = PhysicsCategories.player
    }
    
    func addPlayer() {
        playerNode = PlayerNode(playerEra: .present, mpManager: mpManager)
        playerNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(playerNode)
    }
    
    func addOtherPlayer() {
        guard otherPlayer == nil else { return }
        otherPlayer = OtherPlayerNode(playerEra: .present, mpManager: mpManager)
        otherPlayer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(otherPlayer)
        
    }

    // Update method to control player movement
    override func update(_ currentTime: TimeInterval) {
        self.cameraAndBackgroundUpdate()
        
        // Calculate deltaTime if needed
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Update the platform
        platform.update(deltaTime: deltaTime)
        
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
    
    func cameraAndBackgroundUpdate() {
        cameraNode.position.x = playerNode.position.x
        let cameraMovementX = cameraNode.position.x - previousCameraXPosition
        self.parallaxBackground.moveParallaxBackground(cameraMovementX: cameraMovementX)
        self.parallaxBackground.paginateBackgroundLayers(cameraNode: cameraNode)
        self.previousCameraXPosition = cameraNode.position.x
    }
    
    func setupCamera() {
        self.cameraNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(self.cameraNode)
        self.camera = cameraNode
        self.previousCameraXPosition = cameraNode.position.x
    }

    func setupBackground() {
        self.parallaxBackground = ParallaxBackground(screenSize: self.size, background: BackgroundTexture.desertScene.textures(for: .present))
        
        self.addChild(parallaxBackground!)
    }
}
