//
//  GameScene.swift
//  ChibiNinja
//
//  Created by 井上義晴 on 2015/03/24.
//  Copyright (c) 2015年 tone.youring. All rights reserved.
//

import SpriteKit

class GameScene: SKScene , SKPhysicsContactDelegate{
    
    
    var gameoverLine:SKSpriteNode!
    
    var wallBG = SKNode()//壁用Node
    
    var wallLeft:SKSpriteNode!
    var wallRight:SKSpriteNode!
    
    var climbWallHeight:CGFloat? = nil //登っている壁の高さ
    
    var ninja:SKSpriteNode!
    
    var scoreBG = SKNode()//スコア用Node

    var myLabel:SKLabelNode!
    
    
    var tileTex:SKTexture!
    
    //判定
    
    var _isJump = false
    var _isTouchON = false
    
    var _gameoverFlg = false
    
    var updateCount = 0
    
    struct climbingWall {
        static var UP:CGFloat!
        static var DOWN:CGFloat!
    }
//    var climbLimit_UP:CGFloat!  //登れる高さ
//    var climbLimit_Down:CGFloat!    //降りることのできる高さ

    var power = 0
    let powerMin = 5//最小値
    let powerMid = 10
    let powerMax = 15 //最大値
    let addPower:CGFloat = 3.0 //　power * addPower
    
    var wallBGScreenCenterY:CGFloat!
    

    
    var powerLevel = [SKSpriteNode]()
    
    var wallBGPosY:CGFloat!
    
    var scrollPoint:CGFloat!
    var scrollSpeed:CGFloat!
    
    var ninjaTex_Walk_L = [SKTexture]()
    var ninjaTex_Walk_R = [SKTexture]()
    var ninjaTex_Climb_L = [SKTexture]()
    var ninjaTex_Climb_R = [SKTexture]()
    
    //
    var beganPoint:CGPoint!
    
    enum TouchState:String {
        case Release = "リリース"
        case UP = "UP"
        case DOWN = "DOWN"
        case LEFT = "LEFT"
        case RIGHT = "RIGHT"
        case Neutral = "Neutral" //タッチしているが、beganPoint
    }
    var touchState:TouchState? = .Release
    var touchState_OLD:TouchState? = .Release
    
    enum State:String {
        
        case jump = "Jump"
        case jumping = "Jumping"
        case fall = "fall"
        
        case stop = "Stop"
        case walkLeft = "walkLeft"
        case walkRight = "walkRight"
        
        
        case climbStop_Left = "ClimbStop Left"      //停止
        case climbUp_Left = "ClimbUP Left"    //登る
        case climbDown_Left = "ClimbDown Left"  //降りる
        case climbStop_Right = "ClimbStop Right"//停止
        case climbUp_Right = "ClimbUP Right"    //登る
        case climbDown_Right = "ClimbDown Right"  //降りる

    }
    
    var ninjaState:State? = .fall
    var ninjaState_OLD:State! = .fall
    
    let ninjaCategory:UInt32        = 0x1 << 1      //0001
    let wallCategory:UInt32         = 0x1 << 2      //0010
    let groundCategory:UInt32       = 0x1 << 3      //0100
    let gameoverLineCategory:UInt32 = 0x1 << 4      //1000
    
    

    func initSetting(){
        //画面の半分をスクロールする基準とする
        scrollPoint = self.size.height / 2
        scrollSpeed = 1.0
    }
    
    override func didMoveToView(view: SKView) {
        
        
        
        self.initSetting()
        
      
        
        self.backgroundColor = SKColor.grayColor()
        //self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        self.physicsBody?.categoryBitMask = 0
        self.physicsBody?.contactTestBitMask = 0
        self.physicsBody?.collisionBitMask = 0
        
        //物理シミュレーション設定
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -3.5)
        self.physicsWorld.speed = 0.3
        self.physicsWorld.contactDelegate = self
        
        //中心線
        
        let centerLineX = SKSpriteNode(color: SKColor.whiteColor(), size: CGSize(width: self.size.width, height: 2))
        centerLineX.position = CGPoint(x: 160, y: 240)
        self.addChild(centerLineX)
        centerLineX.zPosition = 10
        //　中央線
        let centerLineY = SKSpriteNode(color: SKColor.whiteColor(), size: CGSize(width: 1, height: self.size.height))
        centerLineY.position = CGPoint(x: 160, y: 240)
        self.addChild(centerLineY)
        centerLineY.zPosition = 10
        
        
    //壁配置用ノード
        wallBG.scene?.size = self.size
        self.addChild(wallBG)
        
        wallBGPosY = wallBG.frame.size.height / 2
        
    //スコア用ノード
        scoreBG.scene?.size = self.size
        self.addChild(scoreBG)

    // ゲームオーバー用
        let gameoverLine = SKSpriteNode(color: SKColor.clearColor(), size: CGSize(width: self.size.width * 2, height: 10))
        gameoverLine.position = CGPoint(x:self.size.width / 2, y: -100)
        gameoverLine.name = "gameoverLine"
        self.addChild(gameoverLine)
        gameoverLine.physicsBody = SKPhysicsBody(edgeLoopFromRect: gameoverLine.frame)
        gameoverLine.physicsBody?.categoryBitMask = gameoverLineCategory
        gameoverLine.physicsBody?.contactTestBitMask = ninjaCategory
        gameoverLine.physicsBody?.collisionBitMask = ninjaCategory
        
        self.gameoverLine = gameoverLine
        
    //高さ表示ラベル
        myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "0 m";
        myLabel.fontSize = 25;
        myLabel.fontColor = SKColor.blackColor()
        myLabel.position = CGPoint(x:250, y:10)
        myLabel.zPosition = 2
        scoreBG.addChild(myLabel)
        
        touchStateLabel = SKLabelNode(fontNamed:"Chalkduster")
        touchStateLabel.text = "touchstate";
        touchStateLabel.fontSize = 25;
        touchStateLabel.fontColor = SKColor.blackColor()
        touchStateLabel.position = CGPoint(x:100, y:400)
        touchStateLabel.zPosition = 2
        scoreBG.addChild(touchStateLabel)
        
        ninjaStateLabel = SKLabelNode(fontNamed:"Chalkduster")
        ninjaStateLabel.text = "ninjastate";
        ninjaStateLabel.fontSize = 25;
        ninjaStateLabel.fontColor = SKColor.blackColor()
        ninjaStateLabel.position = CGPoint(x:100, y:450)
        ninjaStateLabel.zPosition = 2
        scoreBG.addChild(ninjaStateLabel)
        
    //地面の作成
        let ground = make_Wall(CGSize(width: self.size.width, height: 20))
        ground.position = CGPoint(x: self.size.width / 2, y: -10)
        ground.color = SKColor.redColor()
        ground.name = "ground"
        ground.zPosition = 0
        wallBG.addChild(ground)
//        ground.physicsBody = SKPhysicsBody(edgeLoopFromRect: ground.frame)
//        ground.physicsBody?.categoryBitMask =
//        ground.physicsBody?.dynamic = false
        
        
        // 壁の作成 //---------------------
        
        var wallHeight:CGFloat = 0.0
        
        for i in 0...10 {
            
            //ランダムな壁サイズを作る
            let wallSize = CGSize(
                width:random_X_Size(UInt32(self.size.width / 4), maxWidth: UInt32(self.size.width / 2)),
                height:random_Y_Size(UInt32(self.size.height / 8), maxHeight: UInt32(self.size.height / 4)))
            
            
            wallLeft = make_Wall(wallSize)
            wallRight = make_Wall(wallSize)
            
            wallLeft.position = CGPoint(x:0, y: wallHeight)

            println("\(i) : \(wallLeft.position.x)")
            
            //壁と壁の間をランダムで作る

            //Right Wall
            wallRight.position = CGPoint(x:self.size.width, y:wallHeight)
            
            wallLeft.name   = "wallLeft"
            wallRight.name  = "wallRight"
 
            wallBG.addChild(wallLeft)
            wallBG.addChild(wallRight)
            
            wallHeight +=  CGFloat(wallLeft.size.height)
            
        }
        
        //------------------------------
        
        ninjaTex_Walk_L = [
            SKTexture(imageNamed: "walk_L1"),
            SKTexture(imageNamed: "walk_L2"),
            SKTexture(imageNamed: "walk_L3"),
            SKTexture(imageNamed: "walk_L2")]
        ninjaTex_Walk_R = [
            SKTexture(imageNamed: "walk_R1"),
            SKTexture(imageNamed: "walk_R2"),
            SKTexture(imageNamed: "walk_R3"),
            SKTexture(imageNamed: "walk_R2")]
        ninjaTex_Climb_L = [
            SKTexture(imageNamed: "climb_L1.png"),
            SKTexture(imageNamed: "climb_L2.png")
        ]
        ninjaTex_Climb_R = [
            SKTexture(imageNamed: "climb_R1.png"),
            SKTexture(imageNamed: "climb_R2.png")
            
        ]
    //Power Level
        make_powerLevel()
        
    //ninja
        make_Ninja()
        
    }
    
    //MARK:ジャンプパワー表示
    func make_powerLevel(){
        
        for i in 0 ..< powerMax{
            var sprite = SKSpriteNode()
            if i < powerMin{
                sprite = SKSpriteNode(color: SKColor.blueColor(), size: CGSize(width: 7, height: 12 + CGFloat(i * 2)))
            }else if i < powerMid {
                sprite = SKSpriteNode(color: SKColor.yellowColor(), size: CGSize(width: 7, height: 12 + CGFloat(i * 2)))
            }else{
                sprite = SKSpriteNode(color: SKColor.redColor(), size: CGSize(width: 7, height: 12 + CGFloat(i * 2)))
                
            }
            
            sprite.hidden = true
            sprite.zPosition = 2
            sprite.position = CGPoint(x: 20.0 + sprite.size.width * 2 * CGFloat(i), y: 10)
            
            scoreBG.addChild(sprite)
            powerLevel.append(sprite)
        }
        
    }
    
    func make_TextureTile(texName:String,numderVirtical:UInt,numberHorizontal:UInt) ->[SKTexture]{
        var array = [SKTexture]()
        let texture = SKTexture(imageNamed: texName)
        let width = CGFloat(texture.size().width / CGFloat(numderVirtical))
        let heigt = CGFloat(texture.size().height / CGFloat(numberHorizontal))
        
        // Gal textureパターン
        for j in 0 ..< numderVirtical {
            for i in  0 ..< numberHorizontal {
                let tex = SKTexture(rect:CGRect(x:CGFloat(i / numberHorizontal), y:CGFloat(j / numderVirtical), width:width, height:heigt),inTexture: texture)
                array.append(tex) // addObject(tex)
            }
        }
        return array
    }
    
    //MARK:ランダム値作成
    func randomXpos(x:UInt32) -> CGFloat{
        return CGFloat(arc4random_uniform(x))
    }
    
    func random_X_Size(minWidth:UInt32,maxWidth:UInt32) -> CGFloat{
         let width = arc4random_uniform(maxWidth) + minWidth
        return CGFloat(width)
    }
    func random_Y_Size(minHeight:UInt32,maxHeight:UInt32) -> CGFloat{
        let height = arc4random_uniform(maxHeight) + minHeight
        return CGFloat(height)
    }

    
    func make_Wall(size:CGSize) -> SKSpriteNode{
        
        let wallColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1)
        let sprite = SKSpriteNode(color: wallColor, size: size)
        
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        sprite.name = "wall"
        
        sprite.physicsBody = SKPhysicsBody(edgeLoopFromRect: sprite.frame)
        //sprite.physicsBody?.linearDamping = 0.0
        sprite.physicsBody?.friction = 1.0
      sprite.physicsBody?.restitution = 0.0
        sprite.physicsBody?.usesPreciseCollisionDetection = true
        
        sprite.physicsBody?.categoryBitMask = wallCategory
        sprite.physicsBody?.contactTestBitMask = 2
        sprite.physicsBody?.collisionBitMask = 2
        return sprite
    }
    //MARK:プレイヤー作成
    func make_Ninja(){
        
        ninja = SKSpriteNode(texture: SKTexture(imageNamed: "ninja_front1.png"))
        
        ninja.setScale(2.0)
        ninja.position = CGPoint(x: self.size.width / 2, y: 50)

        ninja.name = "ninja"
        wallBG.addChild(ninja)
        
        ninja.physicsBody = SKPhysicsBody(circleOfRadius: ninja.size.width/2)
        ninja.physicsBody?.friction = 1.0

        ninja.physicsBody?.restitution = 0.0
        ninja.physicsBody?.allowsRotation = false
        ninja.physicsBody?.usesPreciseCollisionDetection = true
        ninja.physicsBody?.mass = 0.1
        
        ninja.physicsBody?.categoryBitMask      = ninjaCategory
        ninja.physicsBody?.contactTestBitMask   = wallCategory | groundCategory | gameoverLineCategory
        ninja.physicsBody?.collisionBitMask     = wallCategory | groundCategory | gameoverLineCategory

    }
    
//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
//MARK:忍者アクション分岐
    func ninjaAction() {
        
        switch ninjaState! {
        case .stop,.walkLeft,.walkRight:
            walkAction()
            
            //左の壁を登っている
        case .climbStop_Left, .climbUp_Left, .climbDown_Left:
            climbAction_LeftWall()
            
            //右の壁を登っている
        case .climbStop_Right, .climbUp_Right, .climbDown_Right:
            climbAction_RightWall()
            
        case .jump:
            jumpAction()
        case .fall:
            let state = State.fall
            if ninjaState_OLD != state{
            println("落下中")
             ninjaState_OLD = state
            }
            
        default:
            println("\(__FUNCTION__) default")
            
        }
        
    }
    
    //MARK:忍者のアクションを削除
    func removeNinjaAction(){

//        println(ninja.hasActions())
        if ninja.hasActions() == true{
            ninja.removeAllActions()
            println("忍者アクション削除\(__FUNCTION__)")
        }
    }

    
    //MARK:左の壁
    func climbAction_LeftWall(){
        switch touchState!{
            
        case .UP:

            //壁の高さチェック
            if climbingWall.UP < ninja.position.y{
                ninjaState = .climbUp_Left
                if ninjaState_OLD != ninjaState {
                    //他のアクションがあれば削除
                    removeNinjaAction()
                    
                    println("左壁、登る")
                    let move = SKAction.moveBy(CGVector(dx: 0, dy: 5), duration: 0.4)
                    let animation = SKAction.animateWithTextures(ninjaTex_Climb_L, timePerFrame: 0.2)
                    let action = SKAction.group([move,animation])
                    ninja.runAction(SKAction.repeatActionForever(action))
                    
                    ninjaState_OLD = ninjaState
                }
            }
            
            
        case .DOWN:
            //壁の高さチェック
            if climbingWall.UP != nil && climbingWall.DOWN > ninja.position.y{
                
                ninjaState = .climbDown_Left
                if ninjaState_OLD != ninjaState {
                    //他のアクションがあれば削除
                    removeNinjaAction()
                    
                    println("左壁、降りる")
                    
                    let move = SKAction.moveBy(CGVector(dx: 0, dy: -5), duration: 0.4)
                    let animation = SKAction.animateWithTextures(ninjaTex_Climb_L, timePerFrame: 0.2)
                    let action = SKAction.group([move,animation])
                    
                    ninja.runAction(SKAction.repeatActionForever(action))
                    
                    ninjaState_OLD = ninjaState
                }
            }
        case .Neutral:
            ninjaState = .climbStop_Left
            if ninjaState_OLD != ninjaState {
                removeNinjaAction()
                
                ninja.physicsBody?.dynamic = false
                println("左壁に停止")
                ninjaState_OLD = ninjaState
                
            }
        case .Release:
            ninjaState = .climbStop_Left
            if ninjaState_OLD != ninjaState {
                removeNinjaAction()
                
                ninja.physicsBody?.dynamic = true
                println("左壁から落下")
                ninjaState_OLD = .fall; println("ninjaState fall")
                
            }
            
        default:
            println("\(__FUNCTION__) default")
            
        }
    }
    
    
//MARK:右の壁
    func climbAction_RightWall(){
        switch touchState!{
            
        case .UP:
            ninjaState = .climbUp_Right
            if ninjaState_OLD != ninjaState {
                //他のアクションがあれば削除
             //   removeNinjaAction()
                
                println("右壁、登る")
                
                //                    println("右へ移動")
                let move = SKAction.moveBy(CGVector(dx: 0, dy: 5), duration: 0.4)
                let animation = SKAction.animateWithTextures(ninjaTex_Climb_R, timePerFrame: 0.2)
                let action = SKAction.group([move,animation])
                
                ninja.runAction(SKAction.repeatActionForever(action))
                
                ninjaState_OLD = ninjaState
            }
            
            
        case .DOWN:
            ninjaState = .climbDown_Right
            if ninjaState_OLD != ninjaState {
                //他のアクションがあれば削除
             //   removeNinjaAction()
                
                println("右壁、降りる")
                let move = SKAction.moveBy(CGVector(dx: 0, dy: -5), duration: 0.4)
                let animation = SKAction.animateWithTextures(ninjaTex_Climb_R, timePerFrame: 0.2)
                
                let action = SKAction.group([move,animation])
                
                ninja.runAction(SKAction.repeatActionForever(action))
                
                ninjaState_OLD = ninjaState
            }
            
        case .Neutral:
            ninjaState = .climbStop_Right
            if ninjaState_OLD != ninjaState {
                removeNinjaAction()
                
                println("右壁に停止")
                 ninja.physicsBody?.dynamic = false
                ninjaState_OLD = ninjaState
                
            }
            
        case .Release:
            ninjaState = .climbStop_Right
            if ninjaState_OLD != ninjaState {
                removeNinjaAction()
                ninja.physicsBody?.dynamic = true
                println("右壁から落下する")
                ninjaState_OLD = .fall; println("ninjaState fall")
            }
            
        default:
            println("\(__FUNCTION__) default")
        }

    }
    
//MARK:歩く（地面）
    func walkAction(){
        switch touchState! {
        case .LEFT:
            ninjaState = .walkLeft
            
            if ninjaState_OLD != ninjaState {
                removeNinjaAction()
                println("touch LEFT")
                let move = SKAction.moveBy(CGVector(dx: -15, dy: 0), duration: 0.4)
                let animation = SKAction.animateWithTextures(ninjaTex_Walk_L, timePerFrame: 0.1)
                let action = SKAction.group([move,animation])
                ninja.runAction(SKAction.repeatActionForever(action))
                
                ninjaState_OLD = ninjaState
                println("左へ歩く")
            }
            
        case .RIGHT:
            
            ninjaState! = .walkRight
            if ninjaState_OLD != ninjaState {
                //他のアクションがあれば削除
                removeNinjaAction()
                
                println("touch RIGHT")
                
                let move = SKAction.moveBy(CGVector(dx: 15, dy: 0), duration: 0.4)
                let animation = SKAction.animateWithTextures(ninjaTex_Walk_R, timePerFrame: 0.1)
                
                let action = SKAction.group([move,animation])
                
                ninja.runAction(SKAction.repeatActionForever(action))
                
                ninjaState_OLD = ninjaState
                println("右へ歩く")
            }
            
        case .Neutral:
            println("touch Neutral")
            ninjaState = .stop
            if ninjaState_OLD != .stop {

                removeNinjaAction()
                
                ninja.texture = SKTexture(imageNamed:"ninja_front1.png")
                
                ninjaState_OLD = ninjaState
            }
            
        case .Release:
            
            ninjaState = .stop
            if ninjaState_OLD != .stop {
                
                println("touch Release")
                
                removeNinjaAction()
                
                ninja.texture = SKTexture(imageNamed:"ninja_front1.png")
                
                ninjaState_OLD = ninjaState
            }
        default:
            println("\(__FUNCTION__) default")
        }
    }
    
    
//== jump methed start ================
//MARK:ジャンプ
    func jumpAction(){
        
        //すでにジャンプ中じゃない事の確認
        if ninjaState_OLD != .jumping {
            
            
                let dxPower = addPower * CGFloat(power)
                let dyPower = addPower * CGFloat(power)
            
                // 忍者のX位置から、ジャンプ方向を決める
                if ninja.position.x >= self.size.width / 2{
                    
                // Left jump
                    ninjaAction_JumpLeft(dxPower: dxPower, dyPower: dyPower)
                    
                }else{
                // Right jump
                    ninjaAction_JumpRight(dxPower: dxPower, dyPower: dyPower)
                }
          
        }
        
    }
    
    func jump(cgVector:CGVector){
        ninja.physicsBody?.dynamic = true
        //ninja.physicsBody?.applyImpulse(cgVector)
        ninja.physicsBody?.applyImpulse(CGVector(dx: cgVector.dx, dy: 10))
        
        println("dy = \(cgVector.dy)")
        power = 0
    }
    
    //MARK:左ジャンプ
    func ninjaAction_JumpLeft(#dxPower:CGFloat,dyPower:CGFloat){
        
        ninja.texture = SKTexture(imageNamed: "jump_L.png")
            //通常のジャンプ
        let action = SKAction.runBlock({
            self.jump(CGVector(dx:-dxPower , dy: dyPower))
        })

        ninja.runAction(action)
            
        println("\(power)　でジャンプした！\(__FUNCTION__)")
        _isJump = true
        ninjaState_OLD = .jumping
//        power = 0
        
    }

    //MARK:右ジャンプ
    func ninjaAction_JumpRight(#dxPower:CGFloat,dyPower:CGFloat){

        ninja.texture = SKTexture(imageNamed: "jump_R.png")
        
        let action = SKAction.runBlock({
            self.jump(CGVector(dx:dxPower , dy: dyPower))
        })
        ninja.runAction(action)

//        _isJump = true

        println("\(power)　でジャンプした！\(__FUNCTION__)")
        //power = 0
        ninjaState_OLD = .jumping
    }
    
//== jump methed end ================

    //MARK:タッチ　開始
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        //            println(__FUNCTION__)
        _isTouchON = true; myLabel.text = "タッチ開始"
        
        touchState = .Neutral; println("Touch Neutral")
    
        println("タッチ開始")
            for touch in (touches as! Set<UITouch>) {
                let location = touch.locationInNode(self)
                beganPoint = location
            }
    }
    //MARK:タッチ　移動
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            
            let add:CGFloat = 3.0 //誤差
            let limit:CGFloat = add - 1.0
            
            // 原点からLimit以上動いた場合
            if  beganPoint.y + limit <= location.y || beganPoint.y - limit >= location.y ||
                beganPoint.x - limit >= location.x || beganPoint.x + limit <= location.x
            {
                
                //Y判定
                if  beganPoint.y + add < location.y {
                    
                    touchState = .UP
                    
                    if
                        touchState_OLD != TouchState.UP {
                            println("UP")
                            myLabel.text = "↑"
                    }
                    
                }else
                    if beganPoint.y - add > location.y{
                        touchState = .DOWN
                        if touchState_OLD != .DOWN{
                            println("DOWN")
                            myLabel.text = "↓"
                           // touchState_OLD = .DOWN
                        }
                }
                
            
        //X判定
                if  beganPoint.x - add > location.x {
                    touchState = TouchState.LEFT
                    
                    if touchState_OLD != .LEFT{
                        
                        println("LEFT")
                        myLabel.text = "←"
                        //touchState_OLD = .LEFT
                    }
                    
                }else
                    if beganPoint.x + add < location.x{
                        
                        touchState = TouchState.RIGHT
                        
                        if touchState_OLD != .RIGHT{
                            
                            println("RIGHT")
                            myLabel.text = "→"
                        }
                }
                if touchState_OLD != TouchState.Neutral {
                    
                    touchState = .Neutral; println("Touch Neutral")
                    myLabel.text = "Neutral"
                    touchState_OLD = touchState
                }
                
                
            }
        }
        touchState_OLD = touchState
    }
    
    //MARK:タッチ　終了
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        println(__FUNCTION__)
        _isTouchON = false;     println("タッチ解除")
        touchState = .Release;  myLabel.text = "Release"
        
        if ninjaState_OLD != nil && ninjaState_OLD != .jumping{
            switch ninjaState_OLD! {
            case .stop:
                ninjaState = .jump
            case .climbStop_Left:
                ninjaState = .jump
            case .climbStop_Right:
                ninjaState = .jump
            default:
                println("\(__FUNCTION__) default")
            }
        }else{
        power = 0
        }
        
        beganPoint = nil
        updateCount = 0
        


    }
 //======
    
    
//MARK:衝突処理
    func didBeginContact(contact: SKPhysicsContact) {
        println(__FUNCTION__)
        let bodyA = contact.bodyA!
        let bodyB = contact.bodyB!
        
        func set_ClimbHeightLimit(){
            //登れる高さのリミットを設定

            println("bodyA  Height = \(bodyA.node!.frame.height)")
            println("bodyA = posy \(bodyA.node!.position.y)")
            println("ninja.posY = \(ninja.position.y)")
            let down:CGFloat! = bodyA.node!.position.y
            
            climbingWall.DOWN = down
            climbingWall.UP = bodyA.node!.frame.height + climbingWall.DOWN
            println("壁の上限 \(climbingWall.UP)、下限を設定\(climbingWall.DOWN)")
           // println("bodyB = \(bodyB.node?.frame.height)")
            
        }
        
        func delete_ClimbHeightLimit(){
            println("壁の上限値、下限値削除")
            climbingWall.DOWN = nil
            climbingWall.UP = nil
            
        }
       
        //ゲームオーバー用
        if bodyA.node?.name == "gameoverLine" || bodyB.node?.name == "gameoverLine"{
            println("game over")
            self.paused = true
            delete_ClimbHeightLimit()
            
        }
        //地面
        if bodyA.node?.name == "ground"  || bodyB.node?.name == "ground"{
//            println("地面")
            ninja.texture = SKTexture(imageNamed: "ninja_front1.png")
            ninjaState = .stop;     println("忍者スタータス　stop")
            touchState_OLD = .Neutral
           delete_ClimbHeightLimit()
        }

        //左の壁
            if bodyA.node?.name == "wallLeft" || bodyB.node?.name == "wallLeft"{
                ninja.texture = SKTexture(imageNamed: "climb_L1a.png")
                ninjaState = .climbStop_Left;println("忍者スタータス　climbStop　左側")
                set_ClimbHeightLimit()
                ninja.physicsBody?.dynamic = false
        
        }
        //右の壁
            if bodyA.node?.name == "wallRight"  || bodyB.node?.name == "wallRight"{
                ninja.texture = SKTexture(imageNamed: "climb_R1a.png")
                ninjaState = .climbStop_Right;println("忍者スタータス　climbStop　右側")
                ninjaState = .climbStop_Left;println("忍者スタータス　climbStop　左側")
                set_ClimbHeightLimit()
                ninja.physicsBody?.dynamic = false
        }
        
        
     }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */

        ninjaStateLabel.text = "\(ninjaState_OLD!.rawValue)"
        touchStateLabel.text = "\(touchState.rawValue)"
        
        ninjaAction()
        
  //      disp_climingHeigth() //登った高さの表示
        
// 画面タッチ中　ーーーーーーーーーーーーーーーーーーーーーーーーー
        if _isTouchON && updateCount < powerMax{
                //ジャンプするパワー(タッチ中のアップデート回数）
                updateCount++

        }
            // 画面タッチしてない　ーーーーーーーーーーーーーーーーーーーーーーーーー
        else{
            //　ジャンプパワーレベルを削除する
            if power == 0 {
                for sprite in powerLevel {
                    sprite.hidden = true
                }
            }
            
            //            if updateCount > 0 {
            //                power--
            //            }
        }
        jumpPowerFromUpdatecount()
        
        
// 画面半分を超えたらスクロールを開始する　-------
        if ninja.position.y > scrollPoint{
            
            let moveY = ninja.position.y - scrollPoint
        
        wallBG.position = CGPoint(x: wallBG.position.x, y: wallBG.position.y - moveY)
            scrollPoint = scrollPoint + moveY
            
        }


    }
    
//MARK:アップデート回数からパワーに変換
    func jumpPowerFromUpdatecount(){
        
        switch updateCount {
        case 0:
            return
        case 1...5:
            power = updateCount
        case 6...14:
            power = powerMin
        case 15...20:
            power = powerMax
        default:
            power = powerMid
        }
//        println("power = \(power)")
        
        
        disp_jumpPowerLevel()
    }
    
//　ジャンプパワーレベルを表示する
    func disp_jumpPowerLevel(){
        
        if updateCount <= powerMax{
            for i in 0..<updateCount {
                //if powerLevel.count <= power {
                powerLevel[i].hidden = false
            }
        }
    }
    
//MARK:高さの表示
    func disp_climingHeigth(){
        let climingHeight = Int(ninja.position.y / ninja.size.height)
        myLabel.text = "\(climingHeight) m"
        
    }
    
//MARK:GameOver
    func gameover(){
        self.physicsWorld.speed = 0;
        
    }
    
    

}
