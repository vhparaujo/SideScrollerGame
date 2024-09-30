//
//  presentTexture.swift
//  SideScrollerGame
//
//  Created by Eduardo on 24/09/24.
//
import SpriteKit



enum PlayerTextureState: Codable {
    case running
    case idle
    case jumping
    case climbing
    case grabbing
    
    func textures(for era: PlayerEra) -> [SKTexture] {
        switch (self, era) {
            case (.running, .present):
                return SKSpriteNode.loadTextures(prefix: "player-run-present", count: 6)
            case (.running, .future):
                return SKSpriteNode.loadTextures(prefix: "player-run-future", count: 6)

            case (.idle, .present):
                return SKSpriteNode.loadTextures(prefix: "player-idle-present", count: 4)
            case (.idle, .future):
                return SKSpriteNode.loadTextures(prefix: "player-idle-future", count: 4)
                
            case (.jumping, .present):
                return SKSpriteNode.loadTextures(prefix: "player-jump-present", count: 2)
            case (.jumping, .future):
                return SKSpriteNode.loadTextures(prefix: "player-jump-future", count: 2)
                
            case (.climbing, .present):
                return SKSpriteNode.loadTextures(prefix: "player-climb-present", count: 3)
            case (.climbing, .future):
                return SKSpriteNode.loadTextures(prefix: "player-climb-future", count: 3)
                
            case (.grabbing, .present):
                return SKSpriteNode.loadTextures(prefix: "player-grab-present", count: 2)
            case (.grabbing, .future):
                return SKSpriteNode.loadTextures(prefix: "player-grab-future", count: 2)
        }
    }
    
    var timePerFrame: TimeInterval {
        switch self {
            case .running:
                return 0.1
            case .idle:
                return 0.2
            case .jumping:
                return 0.15
            case .climbing:
                return 0.2
            case .grabbing:
                return 0.1
        }
    }
}

extension SKSpriteNode {
    
    static func loadTextures(prefix: String, count: Int) -> [SKTexture] {
        var textures: [SKTexture] = []
        for i in 1...count {
            let texture = SKTexture(imageNamed: "\(prefix)-\(i)")
            textures.append(texture)
        }
        return textures
    }
}
