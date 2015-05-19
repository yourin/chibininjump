//
//  SpriteBlock.swift
//  ChibiNinja
//
//  Created by 井上義晴 on 2015/05/18.
//  Copyright (c) 2015年 tone.youring. All rights reserved.
//


import SpriteKit

class SpriteBlock:SKSpriteNode {
    var sprite:SKSpriteNode!
    
    enum BlockPosition {
        case Top
        case Center
        case Under
    }
    var blockPos:BlockPosition!
    
//    convenience init() {
//        let texture =
//    super.init(texture: SKTexture!, color: UIColor!, size: CGSize)
//    }
//    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.blockPos = .Center
    }
    


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    class func physicsRect(sprite:SKSpriteNode) -> SKSpriteNode{
        let sprite2 = sprite
        sprite2.physicsBody = SKPhysicsBody(rectangleOfSize: sprite2.frame.size)
        sprite2.physicsBody?.affectedByGravity = false
        
        return sprite2
    }
    
    class func physicsEdge(sprite:SKSpriteNode) -> SKSpriteNode{
        let sprite2 = sprite
        sprite2.physicsBody = SKPhysicsBody(edgeLoopFromRect:sprite2.frame)
        
        return sprite2
        
        
    }
    
}
