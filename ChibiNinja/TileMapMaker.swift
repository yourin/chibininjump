//
//  TextureTileMap.swift
//  TileMap
//
//  Created by 義晴井上 on 2015/05/12.
//  Copyright (c) 2015年 youringtone. All rights reserved.
//

import SpriteKit

class TileMapMaker {
    
    var textureName     :String!
    var texture         :SKTexture!
    var numberOfColumns :UInt32!
    var numberOfRows    :UInt32!
    var mapChip         = [SKTexture]()

init(textureFileName:String,numberOfColumns:UInt32,numberOfRows:UInt32){
//    let texture = SKTexture(image: textureFileName)
    
    self.textureName        = textureFileName
    self.numberOfColumns    = numberOfColumns
    self.numberOfRows       = numberOfRows
    self.texture            = SKTexture(imageNamed: textureFileName)
    
    let XSize = CGFloat(1.0 / Double(numberOfColumns))
    let YSize = CGFloat(1.0 / Double(numberOfRows))
//    println("xsize = \(XSize)")
    
    for i in 0..<numberOfRows{
        for j in 0..<numberOfColumns{
//            println("j = \(j)")
            //切り出す位置
            let tilePositionRect = CGRect(
                x:XSize * CGFloat(j) , y:YSize * CGFloat(i), width:XSize, height:YSize )
//            println(tilePositionRect)

            //切り出す
            let tex = SKTexture(rect: tilePositionRect, inTexture: texture)
            mapChip.append(tex)
        }
        println("mapChip = \(mapChip.count)")
        println(self.numberOfColumns)
        println(self.numberOfRows)
        
    }
    
    func makeSprite(mapNum:Int) -> SKSpriteNode{
        let sprite = SKSpriteNode(texture: self.mapChip[mapNum])
        
        return sprite
    }
    
}


}