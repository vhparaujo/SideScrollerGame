//
//  TitleMapNode.swift
//  SideScrollerGame
//
//  Created by Eduardo on 27/09/24.
//

import SpriteKit

class TileMapNode: SKNode {
    
    let tileSize = CGSize(width: 16, height: 16)  // Define the size of each tile
    let tilesetTexture: SKTexture
    var tileMapData: [[Int]]  // 2D array to represent the map data

    init(tilesetImageName: String, tileMapData: [[Int]]) {
        self.tilesetTexture = SKTexture(imageNamed: tilesetImageName)
        self.tileMapData = tileMapData
        super.init()
        createTileMap()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createTileMap() {
        for row in 0..<tileMapData.count {
            for col in 0..<tileMapData[row].count {
                let tileIndex = tileMapData[row][col]
                if tileIndex >= 0 {  // If the tileIndex is valid
                    let tile = createTile(for: tileIndex)
                    tile.position = CGPoint(x: CGFloat(col) * tileSize.width, y: CGFloat(row) * tileSize.height)
                    addChild(tile)
                }
            }
        }
    }

    func createTile(for index: Int) -> SKSpriteNode {
        let cols = Int(tilesetTexture.size().width / tileSize.width)
        let col = index % cols
        let row = index / cols

        let tileRect = CGRect(
            x: CGFloat(col) * tileSize.width / tilesetTexture.size().width,
            y: CGFloat(row) * tileSize.height / tilesetTexture.size().height,
            width: tileSize.width / tilesetTexture.size().width,
            height: tileSize.height / tilesetTexture.size().height
        )

        let texture = SKTexture(rect: tileRect, in: tilesetTexture)
        return SKSpriteNode(texture: texture, size: tileSize)
    }
}
