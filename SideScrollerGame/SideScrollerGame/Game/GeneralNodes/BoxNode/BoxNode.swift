//
//  BoxNode.swift
//  SideScrollerGame
//
//  Created by Eduardo on 25/09/24.
//
import SpriteKit

class BoxNode: SKSpriteNode, Codable {
    var isGrabbed: Bool = false
    var id: UUID
    var mpManager: MultiplayerManager
    
    // Propriedades que queremos codificar
    enum CodingKeys: String, CodingKey {
        case id
        case positionX
        case positionY
        case isGrabbed
    }

    init(mpManager: MultiplayerManager) {
        self.mpManager = mpManager
        self.id = UUID()
        let texture = SKTexture(imageNamed: "box") // Substituir com a textura adequada
        super.init(texture: texture, color: .clear, size: texture.size())
        self.name = "Box"
        self.zPosition = 1
        setupPhysicsBody()
    }

    // Requerido para conformar com Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        let posX = try container.decode(CGFloat.self, forKey: .positionX)
        let posY = try container.decode(CGFloat.self, forKey: .positionY)
        self.isGrabbed = try container.decode(Bool.self, forKey: .isGrabbed)

        // Inicializar o MultiplayerManager de alguma forma (dependente da sua lógica)
        self.mpManager = MultiplayerManager()

        // Inicializar com textura
        let texture = SKTexture(imageNamed: "box")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.position = CGPoint(x: posX, y: posY)
        
        setupPhysicsBody()
    }

    // Requerido para conformar com Codable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(position.x, forKey: .positionX)
        try container.encode(position.y, forKey: .positionY)
        try container.encode(isGrabbed, forKey: .isGrabbed)
    }

    // Necessário para SKSpriteNode
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = true // Gravidade habilitada
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategories.box
        self.physicsBody?.contactTestBitMask = PhysicsCategories.player | PhysicsCategories.ground
        self.physicsBody?.collisionBitMask = PhysicsCategories.ground // Colidir apenas com o chão
        self.physicsBody?.friction = 0.0
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.pinned = false // Começa não fixado
    }

    func update(deltaTime: TimeInterval) {
        if isGrabbed {
            mpManager.sendInfoToOtherPlayers(box: .init(mpManager: mpManager))
        } else {
            if let position = mpManager.firstSceneBoxes[self.id] {
                self.position.x = position.position.x
            }
        }
    }

    // Habilita o movimento quando a caixa é agarrada
    func enableMovement() {
        self.physicsBody?.pinned = false
    }

    // Desabilita o movimento quando a caixa é solta
    func disableMovement() {
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.physicsBody?.angularVelocity = 0
    }
}
