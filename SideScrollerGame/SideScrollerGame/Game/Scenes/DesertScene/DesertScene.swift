import SpriteKit
import SwiftUICore

class DesertScene: SKScene, SKPhysicsContactDelegate {
    var mpManager: MultiplayerManager
    let ground = SKSpriteNode(color: .clear, size: CGSize(width: 10000, height: 50))
    
    private var playerNode: PlayerNode!
    private var otherPlayer: OtherPlayerNode!
    
    var platform: PlatformNode!
    private let box = BoxNode()
    
    private var lastUpdateTime: TimeInterval = 0 // Declare and initialize lastUpdateTime

    override func didMove(to view: SKView) {
        self.name = "DesertScene"
        self.backgroundColor = .black
        
        physicsWorld.contactDelegate = self
        
        addPlayer()
        addOtherPlayer()
        
        // Add a box to the scene
        box.position = CGPoint(x: 300, y: 100) // Adjust as needed
        addChild(box) // Add a box to the scene
 
        // Define the movement bounds for the platform
        let minX = CGFloat(100)
        let maxX = CGFloat(1000)
        // Initialize and add the platform to the scene
        platform = PlatformNode(minX: minX, maxX: maxX)
        platform.position = CGPoint(x: minX, y: 200) // Set the starting position
        addChild(platform)
        
        setupPhysics()
        
        // Setup binding for other player updates
    }
    
    init(size: CGSize, mpManager: MultiplayerManager) {
        self.mpManager = mpManager
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
        // Calculate deltaTime if needed
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Update the platform
        platform.update(deltaTime: deltaTime)
        
        // Update the player
        playerNode.update(deltaTime: deltaTime)
        
        // Update the other player if it exists
        otherPlayer?.update(deltaTime: deltaTime)

        // Enviar informações do jogador após atualizar
        if let playerInfo = playerNode.getPlayerInfo() {
            mpManager.sendInfoToOtherPlayers(playerInfo: playerInfo)
        }
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
}
