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
        let HitPos     = contact.contactPoint
        
        let y0:CGFloat! = wallNode.position.y - player.size.height / 2
        let y1:CGFloat! = wallNode.position.y + wallNode.size.height
        
        NSLog("壁下限 = %3.0f　上限 = %3.0f PlayerPos = %3.0f",y0,y1,player.position.y)
//        print("横壁下限 = \(y0)　上限 = \(y1)")
        if y0 < HitPos.y && HitPos.y < y1 {
            print("プレイヤーは横壁にあたった")
            return wallSide
        }
        
        
        var x0:CGFloat!//横の幅A点
        var x1:CGFloat!//横の幅B点
        //横幅を設定　x0 から x1
        if contact.bodyA.node?.name == "leftwall"{
            x0 = wallNode.position.x
            //原点から壁の幅　＋　プレイヤーの横幅半分
            x1 = x0 + wallNode.frame.width + player.size.width / 2
            print("プレイヤーは壁の左")
//        print("Left ")
        }else
        if contact.bodyA.node?.name == "rightwall"{
            x1 = wallNode.position.x
            x0 = x1 - wallNode.frame.width  - player.size.width / 2
            print("プレイヤーは壁の右")

//            print("Right ")
        }
        

        print("wallwidth　\(x0) - \(x1)")
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
