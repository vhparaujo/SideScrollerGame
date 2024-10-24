//
//  presentTexture.swift
//  SideScrollerGame
//
//  Created by Eduardo on 24/09/24.
//
import SpriteKit



enum PlayerTextureState: Codable {
    case runningR
    case runningL
    
    case idleR
    case idleL
    case jumping
    case climbing
    case grabbing
    case hurt
    
    func textures(for era: PlayerEra) -> [SKTexture] {
        switch (self, era) {
            //running
            case (.runningR, .present):
                return SKSpriteNode.loadTextures(prefix: "player-present-walk-right", count: 45)
            case (.runningR, .future):
                return SKSpriteNode.loadTextures(prefix: "player-future-walk-right", count: 45)
            case (.runningL, .present):
                return SKSpriteNode.loadTextures(prefix: "player-present-walk-left", count: 45)
            case (.runningL, .future):
                return SKSpriteNode.loadTextures(prefix: "player-future-walk-left", count: 45)
            //idle
            case (.idleR, .present):
                return SKSpriteNode.loadTextures(prefix: "player-present-idle-right", count: 1)
            case (.idleR, .future):
                return SKSpriteNode.loadTextures(prefix: "player-future-idle-right", count: 1)
            case (.idleL, .present):
                return SKSpriteNode.loadTextures(prefix: "player-present-idle-left", count: 1)
            case (.idleL, .future):
                return SKSpriteNode.loadTextures(prefix: "player-future-idle-left", count: 1)
                
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
            
            case (.hurt, .present):
                return SKSpriteNode.loadTextures(prefix: "player-hurt-present", count: 2)
            case (.hurt, .future):
                return SKSpriteNode.loadTextures(prefix: "player-hurt-future", count: 2)
        }
    }
    
    var timePerFrame: TimeInterval {
        switch self {
            case .runningR:
                return 1/100
            case .runningL:
                return 1/100
            case .idleR:
                return 0.2
            case .idleL:
                return 0.2
            case .jumping:
                return 0.15
            case .climbing:
                return 0.2
            case .grabbing:
                return 0.1
            case .hurt:
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
