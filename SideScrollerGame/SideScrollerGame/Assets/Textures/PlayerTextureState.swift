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
    case jumpingL
    case jumpingR
    case climbing
    case grabbingR
    case grabbingL
    case hurt
    
    func textures(for era: PlayerEra) -> [SKTexture] {
        switch (self, era) {
            //running
        case (.runningR, .present):
            return SKSpriteNode.loadTextures(prefix: "player-present-walk-right", count: 45)
        case (.runningL, .present):
            return SKSpriteNode.loadTextures(prefix: "player-present-walk-left", count: 45)
        case (.runningR, .future):
            return SKSpriteNode.loadTextures(prefix: "player-future-walk-right", count: 45)
        case (.runningL, .future):
            return SKSpriteNode.loadTextures(prefix: "player-future-walk-left", count: 45)
            //idle
        case (.idleR, .present):
            return SKSpriteNode.loadTextures(prefix: "player-present-idle-right", count: 1)
        case (.idleL, .present):
            return SKSpriteNode.loadTextures(prefix: "player-present-idle-left", count: 1)
        case (.idleR, .future):
            return SKSpriteNode.loadTextures(prefix: "player-future-idle-right", count: 1)
        case (.idleL, .future):
            return SKSpriteNode.loadTextures(prefix: "player-future-idle-left", count: 1)
            //jumping
        case (.jumpingL, .present):
            return SKSpriteNode.loadTextures(prefix: "player-present-jump-left", count: 35)
        case (.jumpingR, .present):
            return SKSpriteNode.loadTextures(prefix: "player-present-jump-right", count: 35)
        case (.jumpingL, .future):
            return SKSpriteNode.loadTextures(prefix: "player-future-jump-left", count: 35)
        case (.jumpingR, .future):
            return SKSpriteNode.loadTextures(prefix: "player-future-jump-right", count: 35)
            
        case (.climbing, .present):
            return SKSpriteNode.loadTextures(prefix: "player-climb-present", count: 3)
        case (.climbing, .future):
            return SKSpriteNode.loadTextures(prefix: "player-climb-future", count: 3)
            
        case (.grabbingR, .present):
            return SKSpriteNode.loadTextures(prefix: "player-present-push-right", count: 4)
        case (.grabbingR, .future):
            return SKSpriteNode.loadTextures(prefix: "player-future-push-right", count: 4)
        case (.grabbingL, .present):
            return SKSpriteNode.loadTextures(prefix: "player-present-push-left", count: 4)
        case (.grabbingL, .future):
            return SKSpriteNode.loadTextures(prefix: "player-future-push-left", count: 4)
            
        case (.hurt, .present):
            return SKSpriteNode.loadTextures(prefix: "player-hurt-present", count: 2)
        case (.hurt, .future):
            return SKSpriteNode.loadTextures(prefix: "player-hurt-future", count: 2)
        }
    }
    
    var timePerFrame: TimeInterval {
        switch self {
        case .runningR, .runningL:
            return 1/100
        case .idleR, .idleL:
            return 0.2
        case .jumpingL, .jumpingR:
            return 1/50
        case .climbing:
            return 0.2
        case .grabbingR, .grabbingL:
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
