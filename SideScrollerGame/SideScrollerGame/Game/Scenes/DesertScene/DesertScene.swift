import SpriteKit
import SwiftUICore

class DesertScene: SKScene, SKPhysicsContactDelegate {
    var mpManager: MultiplayerManager = .init()
    
    private var playerNode: PlayerNode!
    private var otherPlayer: OtherPlayerNode!
    
    private var parallaxBackground: ParallaxBackground!
    var cameraNode: SKCameraNode = SKCameraNode()
    private let box = BoxNode()
    private let box2 = BoxNode()
    private let fatalBox = SKSpriteNode(color: .clear, size: CGSize(width: 50, height: 50))
    
    var previousCameraXPosition: CGFloat = 0.0
    var platform: PlatformNode!
    
    var tileMapWidth: CGFloat = 0.0
    
    private var lastUpdateTime: TimeInterval = 0 // Declare and initialize lastUpdateTime

    override func didMove(to view: SKView) {
        self.name = "DesertScene"
        self.backgroundColor = .black
        
        physicsWorld.contactDelegate = self
        
        addPlayer()
        addOtherPlayer()
        setupBackground()
        setupCamera()
        
        // Add a box to the scene
        box.position = CGPoint(x: size.width + 100, y: size.height / 2) // Adjust as needed
        addChild(box)        // Add a box to the scene
        
//        fatalBox.position = CGPoint(x: 1200, y: 100)
//        fatalBox.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "fatalBox"), size: CGSize(width: 50, height: 50))
//        fatalBox.physicsBody?.isDynamic = false
//        fatalBox.physicsBody?.categoryBitMask = PhysicsCategories.fatal
//        fatalBox.physicsBody?.contactTestBitMask = PhysicsCategories.player
//        fatalBox.physicsBody?.collisionBitMask = PhysicsCategories.player
//        addChild(fatalBox)
        let elevator = ElevatorNode(mode: .automatic)
        elevator.position = CGPoint(x: 1200, y: 0)
        addChild(elevator)
 
        
        // Define the movement bounds for the platform
        let minX = CGFloat(100)
        let maxX = CGFloat(1000)
        // Initialize and add the platform to the scene
        platform = PlatformNode(minX: minX, maxX: maxX)
        platform.position = CGPoint(x: minX, y: 200) // Set the starting position
        addChild(platform)

                
        let mapBuilder = MapBuilder(scene: self)
        mapBuilder.embedScene(fromFileNamed: "FirstFutureScene")
        tileMapWidth = mapBuilder.tileMapWidth

    }
    
    init(size: CGSize, mpManager: MultiplayerManager) {
        self.mpManager = mpManager
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        self.parallaxBackground = ParallaxBackground(screenSize: self.size, background: BackgroundTexture.firstScene.textures(for: .present))
        
        self.addChild(parallaxBackground!)
    }
}
