//
//  GameScene3.swift
//  ChibiNinja
//
//  Created by 義晴井上 on 2015/08/28.
//  Copyright (c) 2015年 tone.youring. All rights reserved.
//

import Foundation
import SpriteKit

enum WallSide {
    case Upper
    case Side
    case Bottom
}

class GameScene3: SKScene,SKPhysicsContactDelegate {
    
    var _isDebugON = true
    var _isTouchON      = false//タッチ中
    var _gameoverFlg    = false//ゲームオーバー
    
    var gameoverLine:SKSpriteNode!
    var wallBG = SKNode()//壁用Node
    var scoreBG = SKNode()//スコア用Node
    
    var player:Player!//player
    var aryMapChipTexture:TileMapMaker!
    
    var jumpArrowMark:JumpArrowMark!

    
    //
    var beganPoint:CGPoint!
    
    //MARK:衝突カテゴリ
    let playerCategory:      UInt32 = 0x1 << 1      //0001
    let groundCategory:     UInt32 = 0x1 << 10
    let wallLeftCategory:   UInt32 = 0x1 << 11
    let wallRightCategory:  UInt32 = 0x1 << 12

    let gameoverLineCategory:UInt32 = 0x1 << 20
    
    let enemyCategory:UInt32        = 0x1 << 21

    //名前
    let kNinjaName      = "ninja"
    let kLeftWallName   = "leftwall"
    let kRightWallName  = "rightwall"
    let kGroundName     = "ground"
    let kGameOverLineName = "gameoverline"
    let kEnemyName          = "enemy"


    func debug(){
        //中心線
        let centerLineX = SKSpriteNode(color: SKColor.whiteColor(), size: CGSize(width: self.size.width, height: 2))
        centerLineX.position = CGPoint(x:self.size.width / 2, y: self.size.height / 2)
        self.addChild(centerLineX)
        centerLineX.zPosition = 100
        //中央線
        let centerLineY = SKSpriteNode(color: SKColor.whiteColor(), size: CGSize(width: 1, height: self.size.height))
        centerLineY.position = CGPoint(x:self.size.width / 2, y: self.size.height / 2)
        self.addChild(centerLineY)
        centerLineY.zPosition = 100

        
    }
    
    func randomRange(#min:UInt32,max:UInt32) -> UInt32{
        
        let rand = arc4random_uniform(max)+min
        
        return rand
    }
    
    func set_GameGravityAndPhysics(){
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        self.physicsBody?.categoryBitMask = 0
        self.physicsBody?.contactTestBitMask = 0
        self.physicsBody?.collisionBitMask = 0
        
        //物理シミュレーション設定
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        self.physicsWorld.speed = 0.6
        self.physicsWorld.contactDelegate = self

        
    }
    func make_GameOverLine(){
        let gameoverLine = SKSpriteNode(color: SKColor.clearColor(), size: CGSize(width: self.size.width * 2, height: 10))
        gameoverLine.position = CGPoint(x:self.size.width / 2, y: -100)
        gameoverLine.name = "gameoverLine"
        self.addChild(gameoverLine)
        gameoverLine.physicsBody = SKPhysicsBody(edgeLoopFromRect: gameoverLine.frame)
        gameoverLine.physicsBody?.categoryBitMask = gameoverLineCategory
        gameoverLine.physicsBody?.contactTestBitMask = playerCategory
        gameoverLine.physicsBody?.collisionBitMask = playerCategory
        
        self.gameoverLine = gameoverLine

    }
    //MARK:マップチップテクスチャー作成
    func make_MapChipTexture(){
        aryMapChipTexture = TileMapMaker(textureFileName: "map", numberOfColumns: 8, numberOfRows: 16)
        println("mapchip = \(aryMapChipTexture.mapChip.count)")

    }
    
    var groundPosY:CGFloat = 0
    func set_Ground(){
        let ground = aryMapChipTexture.make_MapChipRow_OriginLeft(mapNum: 1, HorizontaCount: 10, physics: true)
        ground.name = kGroundName
        ground.physicsBody?.categoryBitMask  = groundCategory
        ground.physicsBody?.collisionBitMask = playerCategory
        ground.physicsBody?.contactTestBitMask = playerCategory
        
        ground.physicsBody?.restitution = 0.0 //跳ね返らない

        
        wallBG.addChild(ground)
        //        println(ground)
        groundPosY = ground.position.y + ground.size.height
        println("groundPosY = \(groundPosY)")
    }
    

    //壁作成のための 変数
    let stock_NumberOfVertical:UInt32 = 16//縦の在庫数

    var nextPosY_LeftWall:CGFloat = 0//次の縦位置　左
    var nextPosY_RightWall:CGFloat = 0//次の縦位置　右

    var wallLeft_VerticalNumber:UInt32 = 0
    var wallRight_VerticalNumber:UInt32 = 0
    //左の壁
    func make_WallLeft(#mapChipNumber:Int,horizontal:UInt32,vertical:UInt32) ->SKSpriteNode{
        //左下原点の塊を作成
        let sprite =
        aryMapChipTexture.make_MapChipBlock_OriginLeft(
            mapNum: mapChipNumber,
            HorizontaCount: horizontal,
            VerticalCount:  vertical,
            physicsType: .Edge)
        sprite.name = kLeftWallName
        
        sprite.physicsBody?.categoryBitMask = wallLeftCategory
        sprite.physicsBody?.contactTestBitMask = playerCategory
        return sprite
    }
    //右の壁
    func make_WallRight(#mapChipNumber:Int,horizontal:UInt32,vertical:UInt32) ->SKSpriteNode{
        //左下原点の塊を作成
        let sprite =
        aryMapChipTexture.make_MapChipBlock_OriginRight(
            mapNum: mapChipNumber,
            HorizontaCount: horizontal,
            VerticalCount:  vertical,
            physicsType: .Edge)
        sprite.name = kRightWallName
        
        sprite.physicsBody?.categoryBitMask = wallRightCategory
        sprite.physicsBody?.contactTestBitMask = playerCategory
        return sprite
    }
    
    //壁作成
    func set_Wall(mapChipNumber:Int){
       
        var nextYpos:CGFloat = 32.0
        nextPosY_LeftWall = groundPosY
        nextPosY_RightWall = groundPosY
        
        //在庫数を設定
        var stock_LeftBlock = stock_NumberOfVertical
        var stock_RightBlock = stock_NumberOfVertical
        
        //ブロック縦の在庫を返す
        func stockCheck_verticalNumberBlock(#stock:UInt32) -> UInt32{
            
            var number:UInt32 = self.randomRange(min: 1, max: 5)
            if stock < number {
                number = stock
                println("在庫を返す")
            }
            println("number = \(number)")//
            return number
        }

        
        //左壁　在庫がなくなるまで繰り返す
        do{
            let horizontal = self.randomRange(min: 1, max: 4)//
            let vertical = stockCheck_verticalNumberBlock(stock: stock_LeftBlock)
            
        
            //左下原点の塊を作成
            let sprite = make_WallLeft(
                mapChipNumber: mapChipNumber,
                horizontal: horizontal,
                vertical: vertical)
            
            sprite.position = CGPoint(x:0, y: nextPosY_LeftWall )
            wallBG.addChild(sprite)
            
            nextPosY_LeftWall = nextPosY_LeftWall + 32 * CGFloat(vertical)
            
            //在庫から減らす
            stock_LeftBlock -= vertical
            println("stock_LeftBlock = \(stock_LeftBlock)")

            wallLeft_VerticalNumber += vertical
            println("wallLeft_VerticalNumber = \(wallLeft_VerticalNumber) stock_NumberOfVertical = \(stock_NumberOfVertical)")
        } while wallLeft_VerticalNumber != stock_NumberOfVertical
        
        
        
      
        println("stockRightBlock = \(stock_RightBlock)")
        
        //右の壁 在庫がなくなるまで繰り返す
        do{
            let horizontal = self.randomRange(min: 1, max: 4)//
            let vertical = stockCheck_verticalNumberBlock(stock: stock_RightBlock)
            
            
            //右下原点の塊を作成
            let sprite = make_WallRight(
                mapChipNumber: mapChipNumber,
                horizontal: horizontal,
                vertical: vertical)
            
            sprite.position = CGPoint(x:self.size.width, y: nextPosY_RightWall )
            wallBG.addChild(sprite)
            
            nextPosY_RightWall = nextPosY_RightWall + 32 * CGFloat(vertical)
            
            //在庫から減らす
            stock_RightBlock -= vertical
            println("stock_RightBlock = \(stock_RightBlock)")
            
            wallRight_VerticalNumber += vertical
            println("wallRight_VerticalNumber = \(wallRight_VerticalNumber) stock_NumberOfVertical = \(stock_NumberOfVertical)")
        } while wallRight_VerticalNumber != stock_NumberOfVertical

        println("左壁縦の個数 = \(wallLeft_VerticalNumber)")
        println("右壁縦の個数 = \(wallRight_VerticalNumber)")
        
    }
    func set_Player(){
        let player = Player()
        
        player.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMaxY(self.frame))
        player.setScale(2.0)
        self.addChild(player)
        self.player = player

    }//プレイヤー作成
    
    func set_jumpArrow(){
        
        let jumpArrowMark = JumpArrowMark()
        jumpArrowMark.name = "arrowmark"
        //        jumpArrowMark.zRotation = CGFloat(M_PI_2)
        jumpArrowMark.set_rotation(minAngle: 90, maxAngle: -90)
        
        
        //        jumpArrowMark.hidden = true
        jumpArrowMark.hidden = true
        
        player.addChild(jumpArrowMark)
        
        self.jumpArrowMark = jumpArrowMark
        
        self.jumpArrowMark.hidden = true

    }
    
    //MARK:矢印の現在の方向からベクターを返す
    func vectorTojumpArrowAngle() ->CGVector{
        var vector = CGVector()
        let player = self.childNodeWithName("player")
        if let node = player?.childNodeWithName("arrowmark"){
            let arrow = node as! JumpArrowMark
            vector = arrow.jumpVector()
            
        }
        return vector
    }
    //ジャンプする
    func action_PlayerJump(){
        
        if self.player._isJumpNow  == false{
            self.player.physicsBody?.dynamic = true
//            self.player.physicsBody?.velocity = vectorTojumpArrowAngle()
            self.player.jump(vectorTojumpArrowAngle())
            self.player._isJumpNow      = true
            self.jumpArrowMark.hidden   = true
        }else{
            println("ジャンプ中なのでジャンプできない")
        }
        
    }

    
    
    //MARK: -
    override func didMoveToView(view: SKView) {
        
        //背景色
        self.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
        
        //重力と物理を設定
        self.set_GameGravityAndPhysics()
        //物理衝突デリゲート
        self.physicsWorld.contactDelegate = self
        
        //壁配置用ノード
        wallBG.scene?.size = self.size
        
        self.addChild(wallBG)
        
        //スコア用ノード
        scoreBG.scene?.size = self.size
        self.addChild(scoreBG)
        
        // ゲームオーバー用
        self.make_GameOverLine()
        
        //マップチップテクスチャー作成
        self.make_MapChipTexture()
        
        //MARK:地面の作成
        self.set_Ground()
        // 壁の作成
        self.set_Wall(17)
        // 忍者
        self.set_Player()
        //ジャンプマーク
        self.set_jumpArrow()
        
        
        

        //MARK:デバッグモードセット
        if _isDebugON{ self.debug() }
        
    }
    
    func stop_Physics(){
        self.player.physicsBody?.dynamic = false
    }
    
    func show_JumpArrow(){
        self.jumpArrowMark.hidden = false
    }
    
    func hidden_JumpArrow(){
        self.jumpArrowMark.hidden = true

    }
    
    func jump_OK(){
        show_JumpArrow()
        player._isJumpNow = false
    }
    func jump_NO(){
        hidden_JumpArrow()
        player._isJumpNow = true
    }
    
    func change_PlayerState(){
        
    }
    
    //MARK: - 衝突処理
    func didBeginContact(contact: SKPhysicsContact) {
        println("\(__FUNCTION__) A:\(contact.bodyA.node?.name) B: \(contact.bodyB.node?.name)")

        
        //地面
        func on_GroundAndUpperWall (){
            //重力あり、ジャンプ可能
            self.player.direction = .Front
            self.player.state = .Nomal
            jump_OK()
        }
        
        func on_BottomWall(){
            self.player.state = .Fall
            jump_NO()
        }
        
        func onWall_Left(){
            //重力停止
            stop_Physics()
            self.player.direction = .Left
            self.player.state = .WallLeft
            jump_OK()
        }
        func onWall_Right(){
            stop_Physics()
            self.player.direction = .Right
            self.player.state = .WallRight
            jump_OK()
        }


        
        //壁にあたった
        func check_HitWallSide() -> WallSide{
            var wallSide = WallSide.Upper
            //プレイヤーのY位置と衝突スプライトのY位置から壁面（上、横、下）を返す
            //壁の高さ 上面　下面　のY位置を保持する
            let wall_UnderPosY  = contact.bodyA.node!.position.y
            let wall_UpperPosY  = wall_UnderPosY + contact.bodyA.node!.frame.height
            println("up:\(wall_UpperPosY) down:\(wall_UnderPosY) player:\(player.position.y)")
            
            if wall_UpperPosY > player.position.y &&
                wall_UnderPosY < player.position.y{
                    println("横面に当たった")
                    wallSide = .Side
            }else
                //下面よりプレイヤーのY位置が下の場合は下面に当たった
                if player.position.y > wall_UnderPosY {
                    println("下面に当たった")
                    wallSide = .Bottom
            }
            return wallSide
        }
        
// ***     ***********
        if contact.bodyA.node?.name == kGroundName {
            on_GroundAndUpperWall()
        }else
            if contact.bodyA.node?.name == kEnemyName{
                println("敵にあたった")
        }else{
            let side = check_HitWallSide()
            switch side {
            case .Upper:
                on_GroundAndUpperWall()
            case .Bottom:
                on_BottomWall()
                
            case .Side:
                if contact.bodyA.node?.name == kLeftWallName{
                    onWall_Left()
                }else if contact.bodyA.node?.name == kRightWallName{
                    onWall_Right()
                }
            }
        }

    }
    
    
    //MARK: - タッチ処理
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            //ジャンプする
            self.action_PlayerJump()
            
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        
    }
    
    
    
    override func update(currentTime: NSTimeInterval) {
    
        
    }
    override func didEvaluateActions() {
        
    }
    override func didSimulatePhysics() {
        
    }
    
    
}
