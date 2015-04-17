/*
壁クラス

上の面は、歩ける ninjaState.stop

*/

import SpriteKit

class Wall {
    
    let wallCategory:UInt32         = 0x1 << 2      //
    
    class func make_Wall(size:CGSize) -> SKSpriteNode{
        
        let wallColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1)
        let sprite = SKSpriteNode(color: wallColor, size: size)
        
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        sprite.name = "wall"
        
        sprite.physicsBody = SKPhysicsBody(edgeLoopFromRect: sprite.frame)
        //sprite.physicsBody?.linearDamping = 0.0
        sprite.physicsBody?.friction = 1.0
        sprite.physicsBody?.restitution = 0.0
        sprite.physicsBody?.usesPreciseCollisionDetection = true
        
//        sprite.physicsBody?.categoryBitMask = wallCategory
        sprite.physicsBody?.contactTestBitMask = 2
        sprite.physicsBody?.collisionBitMask = 2
        return sprite
    }
}
