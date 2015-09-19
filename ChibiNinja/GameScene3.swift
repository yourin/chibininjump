//
//  GameScene3.swift
//  ChibiNinja
//
//  Created by 義晴井上 on 2015/08/28.
//  Copyright (c) 2015年 tone.youring. All rights reserved.
//

import Foundation
import SpriteKit


class GameScene3: SKScene,SKPhysicsContactDelegate {
    
    var _isDebugON = true
    var _isTouchON      = false//タッチ中
    var _gameoverFlg    = false//ゲームオーバー
    var _gameStart      = false
    
    var gameoverLine:SKSpriteNode!
//    var wallBG = SKNode()//壁用Node
    var wallBG:SKSpriteNode!//壁用Node
    
    var scoreBG = SKNode()//スコア用Node
    
    var player:Player!//player
    var aryMapChipTexture:WallMaker!
    var jumpArrowMark:JumpArrowMark!
    
    var updateCount_Touch = 0

    
    //
    var beganPoint:CGPoint!
    
    //MARK:衝突カテゴリ
    let playerCategory:     UInt32 = 0x1 << 1      //0001
    let groundCategory:     UInt32 = 0x1 << 10
    let wallLeftCategory:   UInt32 = 0x1 << 11
    let wallRightCategory:  UInt32 = 0x1 << 12

    let gameoverLineCategory:UInt32 = 0x1 << 20
    
    let enemyCategory:      UInt32  = 0x1 << 21

    //名前
    let kNinjaName      = "ninja"
    let kLeftWallName   = "leftwall"
    let kRightWallName  = "rightwall"
    let kGroundName     = "ground"
    let kGameOverLineName = "gameoverline"
    let kEnemyName          = "enemy"

//MARK: - FUNCTION
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
    
    func randomRange(min min:UInt32,max:UInt32) -> UInt32{
        
        let rand = arc4random_uniform(max)+min
        
        return rand
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
        
        aryMapChipTexture = WallMaker(textureFileName: "map", numberOfColumns: 8, numberOfRows: 16)
        print("mapchip = \(aryMapChipTexture.mapChip.count)")

    }
    
    var groundPosY:CGFloat = 0
    func set_Ground(){
        let ground = aryMapChipTexture.make_MapChipRow_OriginLeft(mapNum: 1, HorizontaCount: 10, physics: true)
        ground.name = kGroundName
        ground.physicsBody?.categoryBitMask  = groundCategory
        ground.physicsBody?.collisionBitMask = playerCategory
        ground.physicsBody?.contactTestBitMask = playerCategory
        
        ground.physicsBody?.restitution = 0.0 //跳ね返らない
        ground.physicsBody?.friction = 1.0

//        self.addChild(ground)
        wallBG.addChild(ground)
        //        print(ground)
        groundPosY = ground.position.y + ground.size.height
        print("groundPosY = \(groundPosY)")
    }
    func set_GameGravityAndPhysics(){
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        self.physicsBody?.categoryBitMask = 0
        self.physicsBody?.contactTestBitMask = 0
        self.physicsBody?.collisionBitMask = 0
        
        //物理シミュレーション設定
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        self.physicsWorld.speed = 0.5
        self.physicsWorld.contactDelegate = self
        
    }
    

    //壁作成のための 変数
    let stock_NumberOfVertical:UInt32 = 32//縦の在庫数
    var nextPosY_LeftWall:CGFloat = 0//次の縦位置　左
    var nextPosY_RightWall:CGFloat = 0//次の縦位置　右

    var wallLeft_VerticalNumber:UInt32 = 0
    var wallRight_VerticalNumber:UInt32 = 0
    //左の壁
    func make_WallLeft(mapChipNumber:Int,horizontal:UInt32,vertical:UInt32) ->SKSpriteNode{
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
        sprite.physicsBody?.restitution = 0.0 //跳ね返らない
        sprite.physicsBody?.friction = 1.0
        return sprite
    }
    //右の壁
    func make_WallRight(mapChipNumber:Int,horizontal:UInt32,vertical:UInt32) ->SKSpriteNode{
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
        sprite.physicsBody?.restitution = 0.0 //跳ね返らない
        sprite.physicsBody?.friction = 1.0
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
        func stockCheck_verticalNumberBlock(stock:UInt32) -> UInt32{
            
            var number:UInt32 = self.randomRange(min: 1, max: 5)
            if stock < number {
                number = stock
                print("在庫を返す")
            }
            print("number = \(number)")//
            return number
        }

        
        //左壁　在庫がなくなるまで繰り返す
        repeat{
            let horizontal = self.randomRange(min: 1, max: 4)//
            let vertical = stockCheck_verticalNumberBlock(stock_LeftBlock)
            
        
            //左下原点の塊を作成
            let sprite = make_WallLeft(
                mapChipNumber,
                horizontal: horizontal,
                vertical: vertical)
            
            sprite.position = CGPoint(x:0, y: nextPosY_LeftWall )
            wallBG.addChild(sprite)
//            self    .addChild(sprite)
            
            nextPosY_LeftWall = nextPosY_LeftWall + 32 * CGFloat(vertical)
            
            //在庫から減らす
            stock_LeftBlock -= vertical
            print("stock_LeftBlock = \(stock_LeftBlock)")

            wallLeft_VerticalNumber += vertical
            print("wallLeft_VerticalNumber = \(wallLeft_VerticalNumber) stock_NumberOfVertical = \(stock_NumberOfVertical)")
        } while wallLeft_VerticalNumber != stock_NumberOfVertical
        
        
        
      
        print("stockRightBlock = \(stock_RightBlock)")
        
        //右の壁 在庫がなくなるまで繰り返す
        repeat{
            let horizontal = self.randomRange(min: 1, max: 4)//
            let vertical = stockCheck_verticalNumberBlock(stock_RightBlock)
            
            
            //右下原点の塊を作成
            let sprite = make_WallRight(
                mapChipNumber,
                horizontal: horizontal,
                vertical: vertical)
            
            sprite.position = CGPoint(x:self.size.width, y: nextPosY_RightWall )
            wallBG.addChild(sprite)
//            self.addChild(sprite)
            
            nextPosY_RightWall = nextPosY_RightWall + 32 * CGFloat(vertical)
            
            //在庫から減らす
            stock_RightBlock -= vertical
            print("stock_RightBlock = \(stock_RightBlock)")
            
            wallRight_VerticalNumber += vertical
            print("wallRight_VerticalNumber = \(wallRight_VerticalNumber) stock_NumberOfVertical = \(stock_NumberOfVertical)")
        } while wallRight_VerticalNumber != stock_NumberOfVertical

        print("左壁縦の個数 = \(wallLeft_VerticalNumber)")
        print("右壁縦の個数 = \(wallRight_VerticalNumber)")
        
    }
    //MARK:プレイヤー作成
    func set_Player(){
        let player = Player()
        
        player.position = CGPoint(
            x: CGRectGetMidX(self.frame),
            y: CGRectGetMaxY(self.frame))
        player.setScale(2.0)
        wallBG.addChild(player)
//        self.addChild(player)
        self.player = player
        self.player._isJumpNow = true

    }//プレイヤー作成
    
    func set_jumpArrow(){
        
        let jumpArrowMark = JumpArrowMark()
        jumpArrowMark.name = "arrowmark"
        player.addChild(jumpArrowMark)
        
        self.jumpArrowMark = jumpArrowMark
        self.jumpArrowMark.hidden = true
    }
    
    //MARK:矢印の角度限界設定
    func change_jumpArrowDirection_Nomal(){
        jumpArrowMark.set_Rotation(minAngle: 90, maxAngle: -90)
    }
    func change_jumpArrowDirection_RightFromLeft(){
        jumpArrowMark.set_Rotation(minAngle: 80, maxAngle: -80)
    }
    func change_jumpArrowDirection_LeftFromRight(){
        jumpArrowMark.set_Rotation(minAngle: -80, maxAngle: 80)
    }
    
    func chenge_jumpArrowDirection_Left(){
        jumpArrowMark.set_Rotation(minAngle: 100.0, maxAngle: 15)
    }
    func chenge_jumpArrowDirection_Right(){
        jumpArrowMark.set_Rotation(minAngle: -100.0, maxAngle: -15)
    }

    
    //MARK:矢印の現在の方向からベクターを返す
    func vectorTojumpArrowAngle() ->CGVector{
        var vector = CGVector()
        
         print("ArrowVector = \(self.jumpArrowMark.jumpVector())")
        let player = self.childNodeWithName("player")
        if let node = player?.childNodeWithName("arrowmark"){
            let arrow = node as! JumpArrowMark
            vector = arrow.jumpVector()
            
        }
        
//        return vector
        return self.jumpArrowMark.jumpVector()
    }
    //MARK:ジャンプする
    func action_PlayerJump(){
        //
        if self.player._isJumpNow  == false{
            start_Physics()
            print("vectorTojumpArrowAngle() = \(vectorTojumpArrowAngle())")
            self.player.jump(vectorTojumpArrowAngle())
            jump_NO()
            hidden_JumpArrow()
        }else{
            print("ジャンプ中なのでジャンプできない")
        }
        
    }
    //MARK:アップデートカウントをリセット
    func reset_updateCount(){
        self.updateCount_Touch = 1
    }
    func chenge_ArrowScale(){
        let newScale:CGFloat = 1.0 + CGFloat(updateCount_Touch / 20)
        self.jumpArrowMark.yScale = newScale
    }
    func reset_ArrowScale(){
        self.jumpArrowMark.yScale = 1.0
    }
//************************************************************
    //MARK: -
    override func didMoveToView(view: SKView) {
        
        //背景色
        self.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
        
        //重力と物理を設定
        self.set_GameGravityAndPhysics()
        //物理衝突デリゲート
        self.physicsWorld.contactDelegate = self
        
        //壁配置用ノード
        wallBG = SKSpriteNode()//color: SKColor.clearColor(), size: self.size)
//        wallBG.scene?.size = self.size
//            //物理シミュレーション設定
//            self.wallBG.scene?.physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
//        self.wallBG.scene?.physicsWorld.speed = 0.5
//        self.wallBG.scene?.physicsWorld.contactDelegate = self

        
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
        //スクロールポイントセット　画面の半分
        self.scrollPosY = CGRectGetMidY(self.frame)
//        self.scrollPoint = self.size.height / 2
        
//MARK:デバッグモードセット
        if _isDebugON{ self.debug() }
        
    }
    //MARK: -
    
    func start_Physics(){
        self.player.physicsBody?.dynamic = true
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
    
    //MARK: - 衝突処理
    func didBeginContact(contact: SKPhysicsContact) {
        print("\(__FUNCTION__) A:\(contact.bodyA.node?.name) B: \(contact.bodyB.node?.name)")

        
        func on_GroundAndUpperWall (){
            
            //ゲームスタート
            if _gameStart != true{
                _gameStart = true
            }
            
            //重力あり、ジャンプ可能
            self.player.direction = .Front
            self.player.chenge_State(State.Nomal)
            
            //矢印の角度変更
            if self.player.position.x < self.size.width / 2 {
                change_jumpArrowDirection_LeftFromRight()
                
            }else{
                change_jumpArrowDirection_RightFromLeft()
            }
            
            jump_OK()
        }//地面
        func on_BottomWall(){
            self.player.chenge_State(State.Fall)
            jump_NO()
            self.player.physicsBody?.velocity = CGVector(dx: 0, dy: -1)
        }//壁下
        func onWall_Left(){
            //重力停止
            stop_Physics()
            self.player.direction = .Left
            self.player.chenge_State(State.WallLeft)
            chenge_jumpArrowDirection_Right()
            jump_OK()
        }//左壁　横
        func onWall_Right(){
            stop_Physics()
            self.player.direction = .Right
            self.player.chenge_State(State.WallRight)
            chenge_jumpArrowDirection_Left()
            jump_OK()
        }//右壁　横
    
// ***     ***********
        if contact.bodyA.node?.name == kGroundName {
            on_GroundAndUpperWall()
        }else
            if contact.bodyA.node?.name == kEnemyName{
                print("敵にあたった")
        }else{
            let side = WallMaker.check_HitWallSide(contact: contact)
//            let side = check_HitWallSide()
            switch side {
            case .Upper:
                on_GroundAndUpperWall()
            case .Bottom:
                on_BottomWall()
                
            case .Side:
                if contact.bodyA.node?.name == kLeftWallName{
                    onWall_Left()
                }else
                if contact.bodyA.node?.name == kRightWallName{
                    onWall_Right()
                }
            }
        }
        
        //スクロールチェック
        check_ScrollPoint()

      
    }
    //MARK: -
    //MARK:画面スクロール
    var scrollPosY:CGFloat!
    func check_ScrollPoint(){

        if scrollPosY < self.player.position.y {
            print("スクロールする")
            
            self.disp_playerPos()
            //スクロールする量を計算
            let moveY:CGFloat! = self.player.position.y - scrollPosY
            self.scroll(moveY)
            scrollPosY = scrollPosY + moveY!
            print("nextScrollPosY = \(scrollPosY)")
            
        }else{
            print("スクロールしない")
        }
    }
    
    func disp_playerPos(){
        print("playerPosX = \(self.player.position.x) Y = \(self.player.position.y)")
  
    }
    
    func scroll(moveY:CGFloat){
//        wallBG.position = CGPoint(x: 0, y: -moveY)
        
        let action = SKAction.moveByX(0, y: -moveY, duration: 1)
        self.wallBG.runAction(action)
//        self.player.runAction(action)
        print("self BGを\(moveY)下げた")
        print("self pos = \(self.wallBG.position.y)")
    }
    

    //MARK: - タッチ処理
    func panelTouch_Start(location location:CGPoint){
        _isTouchON = true
    }
    
    func panelTouch_Ended(location location:CGPoint){
        //ジャンプする
        self.action_PlayerJump()
        _isTouchON = false
    
        self.reset_updateCount()
        self.reset_ArrowScale()
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let location = touch.locationInNode(self)
            self.panelTouch_Start(location: location)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            print(__FUNCTION__, "\(location)")
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let location = touch.locationInNode(self)
            self.panelTouch_Ended(location: location)
        }
        
    }
    
    override func touchesCancelled(touches: Set<UITouch>!, withEvent event: UIEvent!) {
        
    }
    
    
    override func update(currentTime: NSTimeInterval) {
        //タッチ中、
        if self._isTouchON {
            //ジャンプしてない、
            if self.player._isJumpNow == false {
                //カウントが100以下
                if updateCount_Touch < 100{
                    updateCount_Touch++
                    print(updateCount_Touch)
                    self.chenge_ArrowScale()
                }
            }
            
        }
        
        
    }
    
    override func didEvaluateActions() {
        
    }
    override func didSimulatePhysics() {
        if _gameStart == true {
            
//            wallBG.position = CGPoint(x: 0, y: wallBG.position.y - 1)
        }
        
        
//        let pt = self.convertPoint(self.player.position, fromNode: wallBG)
//    wallBG.position = CGPoint(x: 0, y: wallBG.position.y - pt.y)
//        if self.player._isJumpNow == true{
//            self.player.jumpAnimation()
//         }else{
//            print("ジャンプ中じゃない")
//            self.player.zRotation = 0
//        }
    }
    
    
    
    
}
