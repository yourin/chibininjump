//
//  Character.swift
//  ChibiNinja
//
//  Created by 義晴井上 on 2015/09/01.
//  Copyright (c) 2015年 tone.youring. All rights reserved.
//

import Foundation
import SpriteKit

class Character:SKSpriteNode {
    
//    var texture = SKTexture()
    
    enum Direction {
        case Front
        case Back
        case Right
        case Left
    }
    
    var direction:Direction!
    
    
//    init(){
//        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
//        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
//        self.direction = .Front
//        
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
