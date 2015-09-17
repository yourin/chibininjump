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
    
    enum PhysicsType {
        case None
        case Edge
        case Rect
        
    }
    
    init(textureFileName:String,numberOfColumns:UInt32,numberOfRows:UInt32){
        //    let texture = SKTexture(image: textureFileName)
        
 
        
        self.textureName        = textureFileName
        self.numberOfColumns    = numberOfColumns
        self.numberOfRows       = numberOfRows
        self.texture            = SKTexture(imageNamed: textureFileName)
        
        let XSize = CGFloat(1.0 / Double(numberOfColumns))
        let YSize = CGFloat(1.0 / Double(numberOfRows))
        //    print("xsize = \(XSize)")
        
        for i in 0..<numberOfRows{
            for j in 0..<numberOfColumns{
                //            print("j = \(j)")
                //切り出す位置
                let tilePositionRect = CGRect(
                    x:XSize * CGFloat(j) , y:YSize * CGFloat(i), width:XSize, height:YSize )
                //            print(tilePositionRect)
                
                //切り出す
                let tex = SKTexture(rect: tilePositionRect, inTexture: texture)
                mapChip.append(tex)
            }
            print("mapChip = \(mapChip.count)")
            print(self.numberOfColumns)
            print(self.numberOfRows)
            
        }
        
    }
    //MARK:マップの塊(右下原点）作成　縦　横
    func make_MapChipBlock_OriginRight(mapNum mapNum:Int,HorizontaCount:UInt32,VerticalCount:UInt32,physicsType:PhysicsType) -> SKSpriteNode{
        
        let tex:SKTexture = self.mapChip[mapNum]
        var ary      = [SKSpriteNode]()
        var aryColmn    = [SKSpriteNode]()
        
        //テクスチャーからスプライトを作成し配列にする
        for j in 0 ..< VerticalCount {
            
            for i in 0 ..< HorizontaCount {
                let sprite = SKSpriteNode(texture: tex)
                ary.append(sprite)
            }
        }
        
        //ベースとなるスプライト作成
        let width = CGFloat(HorizontaCount) * tex.size().width
        let height = CGFloat(VerticalCount) * tex.size().height
        
        let baseSprite = SKSpriteNode(color: SKColor.clearColor(), size: CGSize(width: width, height: height))
        //左下原点
        baseSprite.anchorPoint = CGPoint(x: 1, y: 0)
        
        
        //ベースにスプライトを貼り付ける原点の計算
        let newOrigin = CGPoint(
            x: tex.size().width / 2 +
                -tex.size().width * CGFloat(HorizontaCount),
            y: -tex.size().height / 2 * CGFloat(VerticalCount - 1) +
                tex.size().height / 2 * CGFloat(VerticalCount))
        
        //ベースにスプライトを貼り付ける
        var textureNumber = 0
        for j in 0 ..< VerticalCount {
            for i in 0 ..< HorizontaCount{
                
                
                ary[textureNumber].position = CGPoint(
                    x:newOrigin.x + tex.size().width * CGFloat(i),
                    y:newOrigin.y + tex.size().height * CGFloat(j))
                baseSprite.addChild(ary[textureNumber])
//                print("blockPos = \(textureNumber):\(ary[textureNumber].position)")
                textureNumber++
            }
        }
        
        //物理ボディ
        switch physicsType {
        case .Edge:
            baseSprite.physicsBody = SKPhysicsBody(edgeLoopFromRect: baseSprite.frame)
        case .Rect:
            baseSprite.physicsBody = SKPhysicsBody(rectangleOfSize:
                baseSprite.size, center: CGPoint(x: 1, y: 0))
        case .None:
            print("物理ボディなし")
            
        }
        
        return baseSprite
        
    }
    
    
    //MARK:シェイプノードにテクスチャーを貼る
//    func make_ShapeNode_Rect(mapNum:Int) -> SKShapeNode{
//        let tex = self.mapChip[mapNum]
//        
//        let shape = SKShapeNode(rectOfSize:tex.size())
//        shape.fillTexture = tex
//        return shape
//    }
    
    //MARK:テクスチャー切り出し
    func make_Texture(mapNum:Int) -> SKTexture{
        
        var tex = SKTexture()
        if self.mapChip.count > mapNum {
            tex = self.mapChip[mapNum]
        }else{
            print("マップチップの引数が間違っている")
            tex = self.mapChip[0]
        }
        return tex
    }
    //MARK:-
    //MARK:テクスチャからスプライト作成
    func make_Sprite(mapNum:Int) -> SKSpriteNode{
        let tex = make_Texture(mapNum)
        let sprite = SKSpriteNode(texture:tex)
        
        return sprite
    }
 
    //MARK:テクスチャからスプライト作成(左下原点)
    func make_Sprite_originLeft(mapNum:Int) -> SKSpriteNode{
        let tex = make_Texture(mapNum)
        let sprite = SKSpriteNode(texture:tex)
        sprite.anchorPoint = CGPoint(x: 0, y: 0)
        return sprite
    }
    
    //MARK:テクスチャからスプライト作成(右下原点
    func make_Sprite_originRight(mapNum:Int) -> SKSpriteNode{
        let tex = make_Texture(mapNum)
        let sprite = SKSpriteNode(texture:tex)
        sprite.anchorPoint = CGPoint(x: 1, y: 0)
        return sprite
    }
    
    //MARK:-
    //MARK:テクスチャからEdge物理ボディ付きのスプライト作成
    func make_SpritePhysicsEdge(mapNum:Int) -> SKSpriteNode{
        let sprite = self.make_Sprite(mapNum)

        let newOrigin = CGPoint(x: -sprite.size.width / 2, y:-sprite.size.height / 2)
        sprite.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: newOrigin, size: sprite.size))

        return sprite
    }
    //MARK:テクスチャからRect物理ボディ付きのスプライト作成
    //** テクスチャからRect物理ボディ付きのスプライト作成 */
    func make_SpritePhysicsRect(mapNum:Int) -> SKSpriteNode{
        let sprite = self.make_Sprite(mapNum)
        
        let newOrigin = CGPoint(x: -sprite.size.width / 2, y:-sprite.size.height / 2)
       
        sprite.physicsBody = SKPhysicsBody(rectangleOfSize:sprite.size)
        
        return sprite
    }
    
    //MARK:テクスチャからEdge物理ボディ付きの左原点スプライト作成
    func make_SpritePhysicsEdge_OriginLeft(mapNum:Int) -> SKSpriteNode{
        let sprite = self.make_Sprite_originLeft(mapNum)
        sprite.physicsBody = SKPhysicsBody(edgeLoopFromRect: sprite.frame)
        
        return sprite
    }

    
    //MARK:テクスチャからRect物理ボディ付きの左原点スプライト作成
    func make_SpritePhysicsRect_OriginLeft(mapNum:Int) -> SKSpriteNode{
        let sprite = self.make_Sprite_originLeft(mapNum)
        sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        
        //self.addPhysics(sprite)
        return sprite
    }
    
    
    //MARK:テクスチャからEdge物理ボディ付きの右原点スプライト作成
    func make_SpritePhysicsEdge_OriginRight(mapNum:Int) -> SKSpriteNode{
        let sprite = self.make_Sprite_originRight(mapNum)
        sprite.physicsBody = SKPhysicsBody(edgeLoopFromRect: sprite.frame)
        
        return sprite
    }
    
    //MARK:テクスチャからRect物理ボディ付きの右原点スプライト作成
    func make_SpritePhysicsRect_OriginRight(mapNum:Int) -> SKSpriteNode{
        let sprite = self.make_Sprite_originRight(mapNum)
        sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        
        return sprite
    }
    
    
    
    //MARK:スプライトに物理ボディをつける
    func addPhysics(sprite:SKSpriteNode) -> SKSpriteNode{
        let newOrigin = CGPoint(x: -sprite.size.width / 2, y:-sprite.size.height / 2)
        //            print("newOrigin = \(newOrigin)")
        sprite.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: newOrigin, size: sprite.size))
        return sprite
    
    }
    //MARK:-
    //MARK:マップチップを横に並べる 物理ボディを付ける　付けない
    func make_MapChipRow(mapNum mapNum:Int,HorizontaCount:UInt32,physics:Bool) -> SKSpriteNode{
        let tex = self.mapChip[mapNum]
        var ary = [SKSpriteNode]()
        
        for i in 0 ..< HorizontaCount {
            let sprite = SKSpriteNode(texture: tex)
  //          sprite.position = CGPoint(x:sprite.size.width * CGFloat(i), y:0)
            ary.append(sprite)
        }
        
        //ベースとなるスプライト作成
        let width = CGFloat(ary.count) * tex.size().width
        let height = tex.size().height
        
        let baseSprite = SKSpriteNode(color: SKColor.clearColor(), size: CGSize(width: width, height: height))
        
        //ベースにスプライトを貼り付ける原点の計算
        let newOrigin = CGPoint(x: -tex.size().width / 2 * CGFloat(HorizontaCount - 1), y:0)

        //ベースにスプライトを貼り付ける
        for i in 0 ..< ary.count{
            
            ary[i].position =
                CGPoint(x:newOrigin.x + tex.size().width * CGFloat(i),
                    y:0 )
            baseSprite.addChild(ary[i])
        }
        
        //物理ボディ
        if physics {
        baseSprite.physicsBody = SKPhysicsBody(edgeLoopFromRect: baseSprite.frame)
            
//            baseSprite.physicsBody = SKPhysicsBody(rectangleOfSize: baseSprite.frame.size)
    
        }
        return baseSprite
    }
    //MARK:マップチップ(原点左下)を横に並べる 物理ボディを付ける　付けない
    func make_MapChipRow_OriginLeft(mapNum mapNum:Int,HorizontaCount:UInt32,physics:Bool) -> SKSpriteNode{
        
        let tex = self.mapChip[mapNum]
        var ary = [SKSpriteNode]()
        
        for i in 0 ..< HorizontaCount {
            let sprite = SKSpriteNode(texture: tex)
            ary.append(sprite)
        }
        
        //ベースとなるスプライト作成
        let width = CGFloat(ary.count) * tex.size().width
        let height = tex.size().height
        
        let baseSprite = SKSpriteNode(color: SKColor.clearColor(), size: CGSize(width: width, height: height))

        //ベースにスプライトを貼り付ける原点の計算
        let newOrigin = CGPoint(
            x:tex.size().width / 2,
            y:tex.size().height / 2)
        print("NewOrigin = \(newOrigin)")
        
        //ベースにスプライトを貼り付ける
        for i in 0 ..< ary.count{
            
            ary[i].position =
            CGPoint(x:newOrigin.x + tex.size().width * CGFloat(i),
                y:newOrigin.y )
        baseSprite.addChild(ary[i])
            
        }
        
        baseSprite.anchorPoint = CGPoint(x: 0, y: 0)
        
        //物理ボディ
        if physics {
            baseSprite.physicsBody = SKPhysicsBody(edgeLoopFromRect: baseSprite.frame)
        }
        return baseSprite
    }
    
    
    //MARK:-
    //MARK:マップチップを縦に並べる 物理ボディを付ける　付けない
    func make_MapChipColumn(mapNum mapNum:Int,VerticalCount:UInt32,physics:Bool) -> SKSpriteNode{
        let tex = self.mapChip[mapNum]
        var ary = [SKSpriteNode]()
        
        for i in 0 ..< VerticalCount {
            let sprite = SKSpriteNode(texture: tex)
            //          sprite.position = CGPoint(x:sprite.size.width * CGFloat(i), y:0)
            ary.append(sprite)
        }
        
        //ベースとなるスプライト作成
        let width =  tex.size().width
        let height = CGFloat(ary.count) * tex.size().height
        
        let baseSprite = SKSpriteNode(color: SKColor.clearColor(), size: CGSize(width: width, height: height))
        
        //ベースにスプライトを貼り付ける原点の計算
        let newOrigin = CGPoint(x: 0, y:-tex.size().height / 2 * CGFloat(VerticalCount - 1))
        
        //ベースにスプライトを貼り付ける
        for i in 0 ..< ary.count{
            
            ary[i].position =
                CGPoint(x:newOrigin.x,
                    y:newOrigin.y + tex.size().height * CGFloat(i) )
            baseSprite.addChild(ary[i])
        }
        
        //物理ボディ
        if physics {
            baseSprite.physicsBody = SKPhysicsBody(edgeLoopFromRect: baseSprite.frame)
            
            //            baseSprite.physicsBody = SKPhysicsBody(rectangleOfSize: baseSprite.frame.size)
            
        }
        return baseSprite
    }
    //MARK:マップチップ(左下原点)を縦に並べる 物理ボディを付ける　付けない
    func make_MapChipColumn_OriginLeft(mapNum mapNum:Int,VerticalCount:UInt32,physics:Bool) -> SKSpriteNode{
        let tex = self.mapChip[mapNum]
        var ary = [SKSpriteNode]()
        
        for i in 0 ..< VerticalCount {
            let sprite = SKSpriteNode(texture: tex)
            //          sprite.position = CGPoint(x:sprite.size.width * CGFloat(i), y:0)
            ary.append(sprite)
        }
        
        //ベースとなるスプライト作成
        let width =  tex.size().width
        let height = CGFloat(ary.count) * tex.size().height
        
        let baseSprite = SKSpriteNode(color: SKColor.clearColor(), size: CGSize(width: width, height: height))
        baseSprite.anchorPoint = CGPoint(x: 0, y: 0)
        
        //ベースにスプライトを貼り付ける原点の計算
        let newOrigin = CGPoint(
            x:tex.size().width / 2 ,
            y:tex.size().height)
        
        //ベースにスプライトを貼り付ける
        for i in 0 ..< ary.count{
            
            ary[i].position =
                CGPoint(
                    x:newOrigin.x,
                    y:newOrigin.y / 2 + (newOrigin.y * CGFloat(i)))
            baseSprite.addChild(ary[i])
        }
        
        //物理ボディ
        if physics {
            baseSprite.physicsBody = SKPhysicsBody(edgeLoopFromRect: baseSprite.frame)
            
            
        }
        return baseSprite
    }

    //MARK:マップの塊作成　縦　横
    func make_MapChipBlock(mapNum mapNum:Int,HorizontaCount:Int,VerticalCount:UInt32,physics:Bool) -> SKSpriteNode{
        
        let tex:SKTexture = self.mapChip[mapNum]
        var ary      = [SKSpriteNode]()
        var aryColmn    = [SKSpriteNode]()
        
        //テクスチャーからスプライトを作成し配列にする
        for j in 0 ..< VerticalCount {
            
            for i in 0 ..< HorizontaCount {
                let sprite = SKSpriteNode(texture: tex)
                ary.append(sprite)
            }
        }
        
            //ベースとなるスプライト作成
            let width = CGFloat(HorizontaCount) * tex.size().width
            let height = CGFloat(VerticalCount) * tex.size().height
            
            let baseSprite = SKSpriteNode(color: SKColor.clearColor(), size: CGSize(width: width, height: height))
        //左下原点
             baseSprite.anchorPoint = CGPoint(x: 0, y: 0)
        
        
            //ベースにスプライトを貼り付ける原点の計算
            let newOrigin = CGPoint(
                x: -tex.size().width / 2 * CGFloat(HorizontaCount - 1),
                y: -tex.size().height / 2 * CGFloat(VerticalCount - 1))
            
            //ベースにスプライトを貼り付ける
        var textureNumber = 0
        for j in 0 ..< VerticalCount {
            for i in 0 ..< HorizontaCount{
                
                
                ary[textureNumber].position = CGPoint(
                        x:newOrigin.x + tex.size().width * CGFloat(i),
                        y:newOrigin.y + tex.size().width * CGFloat(j))

//                    CGPoint(x:newOrigin.x + tex.size().width * CGFloat(i),
//                        y:0 )
                baseSprite.addChild(ary[textureNumber])
                textureNumber++
            }
        }
        
            //物理ボディ
            if physics {
                baseSprite.physicsBody = SKPhysicsBody(edgeLoopFromRect: baseSprite.frame)
                
                //            baseSprite.physicsBody = SKPhysicsBody(rectangleOfSize: baseSprite.frame.size)
                
            }
            return baseSprite
        
    }
    
    func appendPhysics(sprite:SKSpriteNode, physicsType:PhysicsType) ->SKSpriteNode{
        switch physicsType {
        case .None:
            print("物理ボディ　なし")
        case .Edge:
            sprite.physicsBody = SKPhysicsBody(edgeLoopFromRect: sprite.frame)
        print("エッジ物理ボディをセット")
        case .Rect:
            sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        print("ボリューム物理ボディをセット")
        }
        
        return sprite
    }
    
    //MARK:マップの塊作成　縦　横
    func make_MapChipBlock(mapNum mapNum:Int,HorizontaCount:Int,VerticalCount:Int,physicsType:PhysicsType) -> SKSpriteNode{
        
        let tex:SKTexture = self.mapChip[mapNum]
        var ary      = [SKSpriteNode]()
        var aryColmn    = [SKSpriteNode]()
        
        //テクスチャーからスプライトを作成し配列にする
        for j in 0 ..< VerticalCount {
            
            for i in 0 ..< HorizontaCount {
                let sprite = SKSpriteNode(texture: tex)
                ary.append(sprite)
            }
        }
        
        //ベースとなるスプライト作成
        let width = CGFloat(HorizontaCount) * tex.size().width
        let height = CGFloat(VerticalCount) * tex.size().height
        
        let baseSprite = SKSpriteNode(color: SKColor.clearColor(), size: CGSize(width: width, height: height))
        //左下原点
        //             baseSprite.anchorPoint = CGPoint(x: 0, y: 0)
        
        
        //ベースにスプライトを貼り付ける原点の計算
        let newOrigin = CGPoint(
            x: -tex.size().width / 2 * CGFloat(HorizontaCount - 1),
            y: -tex.size().height / 2 * CGFloat(VerticalCount - 1))
        
        //ベースにスプライトを貼り付ける
        var textureNumber = 0
        for j in 0 ..< VerticalCount {
            for i in 0 ..< HorizontaCount{
                
                
                ary[textureNumber].position = CGPoint(
                    x:newOrigin.x + tex.size().width * CGFloat(i),
                    y:newOrigin.y + tex.size().width * CGFloat(j))
                
                //                    CGPoint(x:newOrigin.x + tex.size().width * CGFloat(i),
                //                        y:0 )
                baseSprite.addChild(ary[textureNumber])
                textureNumber++
            }
        }
        
        //物理ボディ
        
        
        return baseSprite
        
    }
    //MARK:マップの塊作成　縦　横
    func make_MapChipBlock_OriginLeft(mapNum mapNum:Int,HorizontaCount:UInt32,VerticalCount:UInt32,physicsType:PhysicsType) -> SKSpriteNode{
        
        let tex:SKTexture = self.mapChip[mapNum]
        var ary      = [SKSpriteNode]()
        var aryColmn    = [SKSpriteNode]()
        
        //テクスチャーからスプライトを作成し配列にする
        for j in 0 ..< VerticalCount {
            
            for i in 0 ..< HorizontaCount {
                let sprite = SKSpriteNode(texture: tex)
                ary.append(sprite)
            }
        }
        
        //ベースとなるスプライト作成
        let width = CGFloat(HorizontaCount) * tex.size().width
        let height = CGFloat(VerticalCount) * tex.size().height
        
        let baseSprite = SKSpriteNode(color: SKColor.clearColor(),
            size: CGSize(
                width: width,
                height: height))
        //左下原点
        baseSprite.anchorPoint = CGPoint(x: 0, y: 0)
        
        
        //ベースにスプライトを貼り付ける原点の計算
        let newOrigin = CGPoint(
            x: tex.size().width / 2,// + CGFloat(HorizontaCount - 1),
            y: tex.size().height / 2)// + CGFloat(VerticalCount - 1))
        
        //ベースにスプライトを貼り付ける
        var textureNumber = 0
        for j in 0 ..< VerticalCount {
            for i in 0 ..< HorizontaCount{
                
                
                ary[textureNumber].position = CGPoint(
                    x:newOrigin.x + tex.size().width * CGFloat(i),
                    y:newOrigin.y + tex.size().width * CGFloat(j))
                
                //                    CGPoint(x:newOrigin.x + tex.size().width * CGFloat(i),
                //                        y:0 )
                baseSprite.addChild(ary[textureNumber])
                textureNumber++
            }
        }
        
        //物理ボディ
        switch physicsType {
        case .Edge:
            baseSprite.physicsBody = SKPhysicsBody(edgeLoopFromRect: baseSprite.frame)
        case .Rect:
            baseSprite.physicsBody = SKPhysicsBody(rectangleOfSize:
                baseSprite.size, center: CGPoint(x: 0, y: 0))
        case .None:
            print("物理ボディなし")
            
        }
        
        return baseSprite
        
    }

    
}