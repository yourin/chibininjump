//
//  WallMaker.swift
//  ChibiNinja
//
//  Created by 義晴井上 on 2015/09/11.
//  Copyright (c) 2015年 tone.youring. All rights reserved.
//

import Foundation
import SpriteKit

enum WallSide {
    case Upper
    case Side
    case Bottom
}


class WallMaker: TileMapMaker {
    
    
    //プレイヤーのY位置と衝突スプライトのY位置から壁面（上、横、下）を返す
    class func check_HitWallSide(#contact: SKPhysicsContact) -> WallSide{
        
        println("コンタクトポイント　\(contact.contactPoint)")
        
        //横面にセット
        var wallSide = WallSide.Side
        
        
        let wallNode    = contact.bodyA.node as! SKSpriteNode
        let player      = contact.bodyB.node as! SKSpriteNode
        
        var x0:CGFloat!
        var x1:CGFloat!
        //横幅を設定　x0 - x1
        if contact.bodyA.node?.name == "leftwall"{
            x0 = wallNode.position.x
            x1 = x0 + wallNode.frame.width
        println("Left ")
        }else
        if contact.bodyA.node?.name == "rightwall"{
            x1 = wallNode.position.x
            x0 = x1 - wallNode.frame.width
            print("Right ")
        }
        println("wall　\(x0) - \(x1)")
        println("contactPoint = \(contact.contactPoint)")
        
        if x0 < contact.contactPoint.x &&
            x1 > contact.contactPoint.x{
                println("プレイヤーは壁の上か下にいる")
                if wallNode.position.y + wallNode.frame.height
                    < contact.contactPoint.y{
                        wallSide = WallSide.Upper
                }else
                    if wallNode.position.y > contact.contactPoint.y{
                        wallSide = WallSide.Bottom
                }
        }
    
        return wallSide
    }
}
