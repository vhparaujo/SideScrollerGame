//
//  SurveillanceCamera.swift
//  SideScrollerGame
//
//  Created by Victor Hugo Pacheco Araujo on 05/11/24.
//

import SpriteKit

class SurveillanceCamera: SKCameraNode {
    
    var visionFieldPosition: CGPoint?
    
    override init() {
        super.init()
        self.position = CGPoint(x: frame.midX, y: frame.midY)
        addShapeNodeVision()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addShapeNodeVision() {
        let visionField = SKShapeNode(rectOf: CGSize(width: 300, height: 200))
        visionField.fillColor = .clear
        visionField.strokeColor = .red
        visionField.position = self.visionFieldPosition ?? CGPoint(x: 0, y: 0)
        self.addChild(visionField)
    }
    
}
