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
    
//    func wallSide(contact: SKPhysicsContact) -> WallSide{
//        
//    }
    
    class func check_HitWallSide(#contact: SKPhysicsContact) -> WallSide{
        
        //仮に上面にセット
        var wallSide = WallSide.Upper
        //プレイヤーのY位置と衝突スプライトのY位置から壁面（上、横、下）を返す
        //壁の高さ 上面　下面　のY位置を保持する
        let wall_UnderPosY  = contact.bodyA.node!.position.y
        let wall_UpperPosY  = wall_UnderPosY + contact.bodyA.node!.frame.height
        let playerPosY = contact.bodyB.node?.position.y
        println("up:\(wall_UpperPosY) down:\(wall_UnderPosY) player:\(playerPosY)")
        
        if wall_UpperPosY > playerPosY &&
            playerPosY > wall_UnderPosY{
                println("横面に当たった")
                wallSide = .Side
        }else
            //下面よりプレイヤーのY位置が下の場合は下面に当たった
            if playerPosY < wall_UnderPosY {
                println("下面に当たった")
                wallSide = .Bottom
            }else{
                println("上面に当たった")
        }
        return wallSide
    }
}
