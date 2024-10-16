//
//  MapBuilder.swift
//  SideScrollerGame
//
//  Created by Eduardo on 03/10/24.
//
import SpriteKit

class MapBuilder {
    
    var scene: SKScene
    var mpManager: MultiplayerManager
    
    var tileMapWidth: CGFloat = 0
    
    // Initialize the BuildMap with the current scene
    init(scene: SKScene, mpManager: MultiplayerManager) {
        self.scene = scene
        self.mpManager = mpManager
    }
    
    // Function to build and embed the scene from a file
    func embedScene(fromFileNamed fileName: String) {
        // Embed the specified scene into the current scene
        if let platformScene = SKScene(fileNamed: fileName) {
            // Process the visible tile map node
            if let tileNode = platformScene.childNode(withName: "Tile Map Node") as? SKTileMapNode {
                processTileMapNode(tileNode)
            }
            // Process the invisible tile map node
            if let invisibleTileNode = platformScene.childNode(withName: "Invisible Tile Map Node") as? SKTileMapNode {
                
                // Set the alpha to 0 to make it invisible
                invisibleTileNode.alpha = 0.0
                processTileMapNode(invisibleTileNode)
            }
        }
    }
    
    // Function to process a tile map node
    func processTileMapNode(_ tileNode: SKTileMapNode) {
        tileNode.setScale(5)
        
        self.tileMapWidth = tileNode.mapSize.width * tileNode.xScale
        
        // Position the tile map at the center of the screen
        tileNode.position = CGPoint(x: tileMapWidth / 2, y: scene.size.height / 2)
        tileNode.zPosition = 1
        
        // Remove any existing physics body on the tile map
        tileNode.physicsBody = nil
        
        // Create a physics layer to hold all the physics bodies
        let physicsLayer = SKNode()
        physicsLayer.position = CGPoint.zero
        scene.addChild(physicsLayer)
        
        // Iterate over each tile to create individual physics bodies
        for col in 0..<tileNode.numberOfColumns {
            for row in 0..<tileNode.numberOfRows {
                // Get the tile definition at this column and row
                if let tileDefinition = tileNode.tileDefinition(atColumn: col, row: row) {
                    // Get the tile's position in tileNode's coordinate system
                    let tilePosition = tileNode.centerOfTile(atColumn: col, row: row)
                    // Convert tile position to the scene's coordinate system
                    let tilePositionInScene = tileNode.convert(tilePosition, to: scene)
                    // Create a node for the tile's physics body
                    let tilePhysicsNode = SKNode()
                    tilePhysicsNode.position = tilePositionInScene
                    tilePhysicsNode.zPosition = tileNode.zPosition
                    // Adjust the physics body size for the tile's scaling
                    let tileSize = CGSize(width: tileNode.tileSize.width * tileNode.xScale,
                                          height: tileNode.tileSize.height * tileNode.yScale)
                    
                    // Identify the tile type
                    if let tileName = tileDefinition.name {
                        switch tileName {
                        case "Ground":
                            // Create the physics body for ground tiles
                            tilePhysicsNode.physicsBody = createRoundedRectanglePhysicsBody(tileSize: tileSize)
                            tilePhysicsNode.physicsBody?.isDynamic = false
                            tilePhysicsNode.physicsBody?.friction = 0
                            tilePhysicsNode.physicsBody?.restitution = 0.0
                            
                            tilePhysicsNode.physicsBody?.categoryBitMask = PhysicsCategories.ground
                            tilePhysicsNode.physicsBody?.contactTestBitMask = PhysicsCategories.player | PhysicsCategories.box
                            tilePhysicsNode.physicsBody?.collisionBitMask = PhysicsCategories.player | PhysicsCategories.box
                        case "Wall":
                            // Create the physics body for wall tiles
                            tilePhysicsNode.physicsBody = createRoundedRectanglePhysicsBody(tileSize: tileSize)
                            tilePhysicsNode.physicsBody?.isDynamic = false
                            tilePhysicsNode.physicsBody?.friction = 0
                            tilePhysicsNode.physicsBody?.restitution = 0.0
                            
                            tilePhysicsNode.physicsBody?.categoryBitMask = PhysicsCategories.wall
                            tilePhysicsNode.physicsBody?.contactTestBitMask = PhysicsCategories.player | PhysicsCategories.box
                            tilePhysicsNode.physicsBody?.collisionBitMask = PhysicsCategories.player | PhysicsCategories.box
                        case "Death":
                            // Create the physics body for death tiles
                            tilePhysicsNode.physicsBody = SKPhysicsBody(rectangleOf: tileSize)
                            tilePhysicsNode.physicsBody?.isDynamic = false
                            tilePhysicsNode.physicsBody?.categoryBitMask = PhysicsCategories.Death
                            tilePhysicsNode.physicsBody?.contactTestBitMask = PhysicsCategories.player
                            tilePhysicsNode.physicsBody?.collisionBitMask = PhysicsCategories.none
                        case "SpawnPoint":
                            tilePhysicsNode.physicsBody = SKPhysicsBody(rectangleOf: tileSize)
                            tilePhysicsNode.physicsBody?.isDynamic = false
                            tilePhysicsNode.physicsBody?.categoryBitMask = PhysicsCategories.spawnPoint
                            tilePhysicsNode.physicsBody?.contactTestBitMask = PhysicsCategories.player
                            tilePhysicsNode.physicsBody?.collisionBitMask = 0
                            
                        case "Elevator":
                            addElavator(position: tilePositionInScene)
                        case "Box":
                            addBox(position: tilePositionInScene)
                        case "Ladder":
                            addLadder(position: tilePositionInScene)
                        default:
                            // Default physics body for other tiles
                            break
                        }
                    }
                    
                    // Add the physics node to the physics layer if it has a physics body
                    if tilePhysicsNode.physicsBody != nil {
                        physicsLayer.addChild(tilePhysicsNode)
                    }
                }
            }
        }
        
        tileNode.removeFromParent()
        // Add the tile node to the scene
        scene.addChild(tileNode)
        
        
    }
    
    func addBox(position: CGPoint) {
        if let scene = scene as? FirstScene {
            if scene.playerEra == .future {
                let newBox = BoxNode(mpManager: mpManager)
                newBox.position = position
                newBox.id = .init()
                newBox.name = "\(newBox.id)"
                scene.addChild(newBox)
                scene.firstSceneGeneralBoxes.append(newBox)
                mpManager.sendInfoToOtherPlayers(content: .init(position: newBox.position, id: newBox.id))
            }
        }
    }
    
    func addElavator(position: CGPoint) {
        if let scene = scene as? FirstScene {
            let newElavator =  ElevatorNode(playerEra: .present, mode: .manual, maxHeight: 400)
            newElavator.position = position
            scene.addChild(newElavator)
        }
    }
    
    func addLadder(position: CGPoint) {
        if let scene = scene as? FirstScene {
            let newLadder = Ladder()
            newLadder.position = position
            scene.addChild(newLadder)
        }
    }
    
    func createRoundedRectanglePhysicsBody(tileSize: CGSize) -> SKPhysicsBody? {
        // Define the rectangle centered at (0,0) since the node's position is set accordingly
        let rect = CGRect(x: -tileSize.width / 2, y: -tileSize.height / 2, width: tileSize.width, height: tileSize.height)
        // Define the corner radius (adjust as needed)
        let cornerRadius = min(tileSize.width, tileSize.height) * 0.2 // 20% of the smallest dimension
        // Create the rounded rectangle path
        let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        // Create the physics body from the path
        let physicsBody = SKPhysicsBody(polygonFrom: path)
        // Enable precise collision detection if necessary
        physicsBody.usesPreciseCollisionDetection = true
        return physicsBody
    }
}
