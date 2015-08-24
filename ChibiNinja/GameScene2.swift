//
//  GameScene2.swift
//  ChibiNinja
//
//  Created by 義晴井上 on 2015/08/17.
//  Copyright (c) 2015年 tone.youring. All rights reserved.
//

import SpriteKit

class GameScene2: SKScene , SKPhysicsContactDelegate{

    
    
    override func didMoveToView(view: SKView) {
    println(__FUNCTION__)
        
        
        
        let center = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        
        
        let p1 = SKShapeNode(circleOfRadius: 10)
        p1.fillColor = SKColor.yellowColor()
        p1.position = self.anchorPoint
        p1.zPosition = 50
        self.addChild(p1)

        let p = SKShapeNode(circleOfRadius: 10)
        p.fillColor = SKColor.redColor()
        p.zPosition = 10
        self.addChild(p)
        p.position = center


        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        var str = [String]()
        var count = 0
        for familyname in UIFont.familyNames(){
//            println(familyname)
//            println(count++)
            
            for fontName in UIFont.fontNamesForFamilyName(familyname as! String) {
                //println(fontName)
                str.append(fontName as! String)
            }
            
        }
        

        
        let label = SKLabelNode(fontNamed: str[22])
        label.text = str[22]
        label.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        label.fontSize = 30
        
        self.addChild(label)
        
        
        
         self.set_mapChip()
//        //左の壁
        var nextYpos:CGFloat = 0.0
        for i in 1...5 {
            let randH = arc4random_uniform(4)+1
            let randV = arc4random_uniform(4)+1
            let sprite = aryMapChipTexture.make_MapChipBlock_OriginLeft(mapNum: 2, HorizontaCount: randH, VerticalCount: randV, physicsType: .Edge)
            
            sprite.position = CGPoint(x:0, y: nextYpos)
            //        sprite.position = center
            nextYpos = nextYpos + 32 * CGFloat(randV)
            println("nextYpos = \(nextYpos)")
            self.addChild(sprite)
        }

        //右の壁
        nextYpos = 0.0
        for i in 1...5 {
            let randH = arc4random_uniform(4)+1
            let randV = arc4random_uniform(4)+1
        let sprite = aryMapChipTexture.make_MapChipBlock_OriginRight(mapNum: 2, HorizontaCount: randH, VerticalCount: randV, physicsType: .Edge)
            
            println("\(i): \(randH) x \(randV)")

            sprite.position = CGPoint(x:self.size.width, y: nextYpos)
//        sprite.position = center
        nextYpos = nextYpos + 32 * CGFloat(randV)
            println("nextYpos = \(nextYpos)")
        self.addChild(sprite)
        }
    }
//    
    
    //MARK:マップチップテクスチャー関連  ///////////////////////////////////////////////////////////////////
    
    
    var aryMapChipTexture:TileMapMaker!
    func set_mapChip(){
        aryMapChipTexture = TileMapMaker(textureFileName: "map", numberOfColumns: 8, numberOfRows: 16)
//        println("mapchip = \(aryMapChipTexture.mapChip.count)")

    }
    
//    func set_Wall(mapNum:Int){
//        var nextYpos = 0.0
//        for i in 1...5 {
//            let randH = arc4random_uniform(5)+1
//            let randV = arc4random_uniform(5)+1
//            let sprite = aryMapChipTexture.make_MapChipBlock_OriginRight(mapNum:mapNum, HorizontaCount: randH, VerticalCount: randV, physicsType: .Edge)
//            
//            println("\(i): \(randH) x \(randV)")
//            
//            sprite.position = CGPoint(x:self.size.width, y: nextYpos)
//            //        sprite.position = center
//            nextYpos = nextYpos + 32.0 * CGFloat(randV)
//            println("nextYpos = \(nextYpos)")
//            self.addChild(sprite)
//            
//            
//        }
//    }

/*
    override func didSimulatePhysics() {
    println(__FUNCTION__)
    }
    
    override func didEvaluateActions() {
         println(__FUNCTION__)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
         println(__FUNCTION__)
    }
    
    func didEndContact(contact: SKPhysicsContact) {
         println(__FUNCTION__)    }
    
    override func update(currentTime: NSTimeInterval) {
         println(__FUNCTION__)
    }
  */
}

