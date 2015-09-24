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
    class func check_HitWallSide(contact contact: SKPhysicsContact) -> WallSide{
        
        print("コンタクトポイント　\(contact.contactPoint)")
        
        //　仮に　横面にセット
        var wallSide = WallSide.Side
        
        
        let wallNode    = contact.bodyA.node as! SKSpriteNode
        let player      = contact.bodyB.node as! SKSpriteNode
        
        var x0:CGFloat!//横の幅A点
        var x1:CGFloat!//横の幅B点
        //横幅を設定　x0 から x1
        if contact.bodyA.node?.name == "leftwall"{
            x0 = wallNode.position.x
            x1 = x0 + wallNode.frame.width + player.size.width
            print("プレイヤーは壁の左")
//        print("Left ")
        }else
        if contact.bodyA.node?.name == "rightwall"{
            x1 = wallNode.position.x
            x0 = x1 - wallNode.frame.width  - player.size.width
            print("プレイヤーは壁の右")

//            print("Right ")
        }
        
        NSLog("%3.0f",x0)
        print("wallwidth　%3.0f - %3.0f",x0,x1)
        print("contactPoint = \(contact.contactPoint)")
        
        if x0 < contact.contactPoint.x &&
            x1 > contact.contactPoint.x{
                
                if wallNode.position.y + wallNode.frame.height
                    < contact.contactPoint.y{
                        wallSide = WallSide.Upper
                        print("プレイヤーは壁の上")
                }else
                    if wallNode.position.y > contact.contactPoint.y{
                        wallSide = WallSide.Bottom
                        print("プレイヤーは壁の下")
                }
        }
    
        return wallSide
    }
}
