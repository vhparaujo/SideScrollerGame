//
//  MapBuilder.swift
//  SideScrollerGame
//
//  Created by Eduardo on 03/10/24.
//

import SpriteKit

class MapBuilder {

    var scene: SKScene
    
    var tileMapWidth: CGFloat = 0
    
    // Initialize the BuildMap with the current scene
    init(scene: SKScene) {
        self.scene = scene
    }
    
    // Function to build and embed the scene from a file
    func embedScene(fromFileNamed fileName: String) {
        // Embed the specified scene into the current scene
        if let platformScene = SKScene(fileNamed: fileName) {
            if let tileNode = platformScene.childNode(withName: "Tile Map Node") as? SKTileMapNode {
                
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
                        if tileNode.tileDefinition(atColumn: col, row: row) != nil {
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
                scene.addChild(tileNode)
            }
        }
    }
}
