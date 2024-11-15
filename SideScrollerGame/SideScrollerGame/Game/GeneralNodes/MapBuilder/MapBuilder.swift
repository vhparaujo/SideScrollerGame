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
    var tileMapHeight: CGFloat = 0
    
    // Initialize the BuildMap with the current scene
    init(scene: SKScene, mpManager: MultiplayerManager = .shared) {
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
        self.tileMapHeight = tileNode.mapSize.height * tileNode.yScale
        
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
                            tilePhysicsNode.physicsBody = SKPhysicsBody(rectangleOf: tileSize)
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
                            addSpawnPoint(position: tilePositionInScene, size: tileSize)
                        case "Elevator":
                            addElevator(position: tilePositionInScene)
                        case "ElevatorAutomatic":
                            addElevatorAutomatic(position: tilePositionInScene)
                        case "Box":
                            addBox(position: tilePositionInScene)
                        case "Ladder":
                            addLadder(position: tilePositionInScene)
                        case "ladder2":
                            addLadder2(position: tilePositionInScene)
                        case "fan":
                            addFanBase(position: tilePositionInScene)
                        case "Player":
                            addPlayer(position: tilePositionInScene)
                        case "OtherPlayer":
                            addOtherPlayer(position: tilePositionInScene)
                        case "Saw":
                            addSaw(position: tilePositionInScene)
                        case "NextScene":
                            addNextSceneNode(position: tilePositionInScene, size: tileSize)
                        case "platform1":
                            addPlatform1(position: tilePositionInScene)
                        case "platform2":
                            addPlatform2(position: tilePositionInScene)
                        case "platform3":
                            addPlatform3(position: tilePositionInScene)
                        case "platform4":
                            addPlatform4(position: tilePositionInScene)
                        case "platform5":
                            addPlatform5(position: tilePositionInScene)
                        case "platform6":
                            addPlatform6(position: tilePositionInScene)
                        case "platform7":
                            addPlatform7(position: tilePositionInScene)
                        case "platform8":
                            addPlatform8(position: tilePositionInScene)
                        case "platform9":
                            addPlatform9(position: tilePositionInScene)
                        case "platform10":
                            addPlatform10(position: tilePositionInScene)
                        case "platform11":
                            addPlatform11(position: tilePositionInScene)
                        case "platform12":
                            addPlatform12(position: tilePositionInScene)
                        case "platform13":
                            addPlatform13(position: tilePositionInScene)
                        case "shiftKeyMap":
                            addImage(position: tilePositionInScene)
                            
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
    
    func addImage(position: CGPoint) {
        if let scene = scene as? FirstScene {
            let newImage = ImageSpriteNode(position: position)
            scene.addChild(newImage)
        }
    }
    
    func addPlatform1(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newPlatform = PlatformNodeY(minY: 100, maxY: 500, position: position, moveSpeed: 200)
            scene.platforms.append(newPlatform)
            scene.addChild(newPlatform)
        }
    }
    
    func addPlatform2(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newPlatform = PlatformNodeY(minY: 0, maxY: 500, position: position, moveSpeed: 200)
            scene.platforms.append(newPlatform)
            scene.addChild(newPlatform)
        }
    }
    
    func addPlatform3(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newPlatform = PlatformNodeY(minY: 0, maxY: 400, position: position, moveSpeed: 200)
            scene.platforms.append(newPlatform)
            scene.addChild(newPlatform)
        }
    }
    
    func addPlatform4(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newPlatform = PlatformNodeY(minY: 0, maxY: 500, position: position, moveSpeed: 200)
            scene.platforms.append(newPlatform)
            scene.addChild(newPlatform)
        }
    }
    
    func addPlatform5(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newPlatform = PlatformNodeY(minY: 100, maxY: 500, position: position, moveSpeed: 200)
            scene.platforms.append(newPlatform)
            scene.addChild(newPlatform)
        }
    }
    
    func addPlatform6(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newPlatform = PlatformNodeY(minY: 50, maxY: 900, position: position, moveSpeed: 200)
            scene.platforms.append(newPlatform)
            scene.addChild(newPlatform)
        }
    }
    
    func addPlatform7(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newPlatform = PlatformNode(minX: 100, maxX: 800, position: position, moveSpeed: 200)
            scene.platforms.append(newPlatform)
            scene.addChild(newPlatform)
        }
    }
    
    func addPlatform8(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newPlatform = PlatformNode(minX: 600, maxX: 800, position: position, moveSpeed: 300)
            scene.platforms.append(newPlatform)
            scene.addChild(newPlatform)
        }
    }
    
    func addPlatform9(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newPlatform = PlatformNode(minX: 100, maxX: 500, position: position, moveSpeed: 500)
            scene.platforms.append(newPlatform)
            scene.addChild(newPlatform)
        }
    }
    
    func addPlatform10(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newPlatform = PlatformNode(minX: 0, maxX: 500, position: position, moveSpeed: 250)
            scene.platforms.append(newPlatform)
            scene.addChild(newPlatform)
        }
    }
    
    func addPlatform11(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newPlatform = PlatformNode(minX: 100, maxX: 700, position: position, moveSpeed: 400)
            scene.platforms.append(newPlatform)
            scene.addChild(newPlatform)
        }
    }
    
    func addPlatform12(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newPlatform = PlatformNode(minX: 50, maxX: 700, position: position, moveSpeed: 400)
            scene.platforms.append(newPlatform)
            scene.addChild(newPlatform)
        }
    }
    
    func addPlatform13(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newPlatform = PlatformNode(minX: 100, maxX: 600, position: position, moveSpeed: 400)
            scene.platforms.append(newPlatform)
            scene.addChild(newPlatform)
        }
    }
    
    func addSpawnPoint(position: CGPoint, size: CGSize) {
        if let scene = scene as? FirstScene {
            let newSpawnPoint = SpawnPointNode(size: size, position: position)
            scene.addChild(newSpawnPoint)
        } else if let scene = scene as? SecondScene {
            let newSpawnPoint = SpawnPointNode(size: size, position: position)
            scene.addChild(newSpawnPoint)
        } else if let scene = scene as? ThirdScene {
            let newSpawnPoint = SpawnPointNode(size: size, position: position)
            scene.addChild(newSpawnPoint)
        }
    }
    
    func addBox(position: CGPoint) {
        if let scene = scene as? FirstScene {
            if scene.playerEra == .future {
                let newBox = BoxNode()
                newBox.position = position
                newBox.id = .init()
                newBox.name = "\(newBox.id)"
                scene.addChild(newBox)
            }
        } else if let scene = scene as? SecondScene {
            if scene.playerEra == .future {
                let newBox = BoxNode()
                newBox.position = position
                newBox.id = .init()
                newBox.name = "\(newBox.id)"
                scene.addChild(newBox)
            }
        } else if let scene = scene as? ThirdScene {
            if scene.playerEra == .future {
                let newBox = BoxNode()
                newBox.position = position
                newBox.id = .init()
                newBox.name = "\(newBox.id)"
                scene.addChild(newBox)
            }
        }
    }
    
    func addElevator(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newElavator =  ElevatorNode(playerEra: .present, mode: .manual, maxHeight: 400)
            newElavator.position = position
            scene.addChild(newElavator)
        }
    }
    
    func addElevatorAutomatic(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newElavator =  ElevatorNode(playerEra: .present, mode: .manual, maxHeight: 400)
            newElavator.position = position
            scene.addChild(newElavator)
        }
    }
    
    func addLadder(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newLadder = Ladder(size: CGSize(width: 80, height: 900))
            newLadder.position = position
            scene.addChild(newLadder)
        }
    }
    
    func addLadder2(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newLadder = Ladder(size: CGSize(width: 80, height: 500))
            newLadder.position = position
            scene.addChild(newLadder)
        }
    }
    
    func addFanBase(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let newFan = fanBase()
            newFan.position = position
            scene.addChild(newFan)
        }
    }
    
    func addPlayer(position: CGPoint) {
        if let scene = scene as? FirstScene {
            scene.playerNode = PlayerNode(playerEra: scene.playerEra)
            scene.playerNode.position = position
            scene.addChild(scene.playerNode)
        } else if let scene = scene as? SecondScene {
            scene.playerNode = PlayerNode(playerEra: scene.playerEra)
            scene.playerNode.position = position
            scene.addChild(scene.playerNode)
        } else if let scene = scene as? ThirdScene {
            scene.playerNode = PlayerNode(playerEra: scene.playerEra)
            scene.playerNode.position = position
            scene.addChild(scene.playerNode)
        }
    }
    
    func addOtherPlayer(position: CGPoint) {
        if let scene = scene as? FirstScene {
            var otherPlayerEra: PlayerEra
            
            if scene.playerEra == .present {
                otherPlayerEra = .future
            } else {
                otherPlayerEra = .present
            }
            
            guard scene.otherPlayer == nil else { return }
            scene.otherPlayer = OtherPlayerNode(playerEra: otherPlayerEra)
            scene.otherPlayer.position = position
            scene.addChild(scene.otherPlayer)
        } else if let scene = scene as? SecondScene {
            var otherPlayerEra: PlayerEra
            
            if scene.playerEra == .present {
                otherPlayerEra = .future
            } else {
                otherPlayerEra = .present
            }
            
            guard scene.otherPlayer == nil else { return }
            scene.otherPlayer = OtherPlayerNode(playerEra: otherPlayerEra)
            scene.otherPlayer.position = position
            scene.addChild(scene.otherPlayer)
        } else if let scene = scene as? ThirdScene {
            var otherPlayerEra: PlayerEra
            
            if scene.playerEra == .present {
                otherPlayerEra = .future
            } else {
                otherPlayerEra = .present
            }
            
            guard scene.otherPlayer == nil else { return }
            scene.otherPlayer = OtherPlayerNode(playerEra: otherPlayerEra)
            scene.otherPlayer.position = position
            scene.addChild(scene.otherPlayer)
        }
    }
    
    func addSaw(position: CGPoint) {
        if let scene = scene as? SecondScene {
            let randomSpeed = CGFloat.random(in: 200...400)
            let saw = SawNode(playerEra: .present, speed: randomSpeed, range: 500)
            saw.position = position
            scene.addChild(saw)
        }
    }
    
    func addNextSceneNode(position: CGPoint, size: CGSize) {
        if let scene = scene as? FirstScene {
            let nextSceneNode = NextSceneNode(size: size, position: position)
            scene.addChild(nextSceneNode)
        } else if let scene = scene as? SecondScene {
            let nextSceneNode = NextSceneNode(size: size, position: position)
            scene.addChild(nextSceneNode)
        } else if let scene = scene as? ThirdScene {
            let nextSceneNode = NextSceneNode(size: size, position: position)
            scene.addChild(nextSceneNode)
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
