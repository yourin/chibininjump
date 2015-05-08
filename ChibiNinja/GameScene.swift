//
//  GameScene.swift
//  ChibiNinja
//
//  Created by 井上義晴 on 2015/03/24.
//  Copyright (c) 2015年 tone.youring. All rights reserved.
//

import SpriteKit

class GameScene: SKScene , SKPhysicsContactDelegate{
    
    var _isDeBugMode = false
    //判定
    
    var _isJump = false
    var _isTouchON = false
    
    var _gameoverFlg = false
    
    var _isJumpTimingON = false//ジャンプの最適なタイミングの計測開始
    var jumpTimingCount = 0
    
    
    var gameoverLine:SKSpriteNode!
    
    var wallBG = SKNode()//壁用Node
    
    
    var wallLeft:SKSpriteNode!
    var wallRight:SKSpriteNode!
    
    var scoreBG = SKNode()//スコア用Node
    var climbWallHeight:CGFloat? = nil //登っている壁の高さ
    var myLabel:SKLabelNode!

    
    var touchStateLabel:SKLabelNode!
    var ninjaStateLabel:SKLabelNode!    
    var tileTex:SKTexture!
    var ninja:SKSpriteNode!
    
    var updateCount = 0
    
    //忍者が登っている壁の高さ上限、下限
    struct ClimbingWall {
        static var UP:CGFloat!//登れる高さ　Y軸
        static var DOWN:CGFloat!//降りることのできる高さ
    }
    //忍者が登っている壁の高さ上面の左右の位置　X軸
    struct WalkingWallLimit {
        static var LEFT:CGFloat!//登れる高さ
        static var RIGHT:CGFloat!//降りることのできる高さ
    }
    
    enum JumpTiming:UInt {
        case VeryFast = 1
        case Fast
        case Best
        case Slow
        case VerySlow
    }
    
    var jumpTiming:JumpTiming? = nil

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
    var touchState_OLD:TouchState! = .Release
    
    enum State:String {
        
        case jump = "Jump"
        case jumping = "Jumping"
        case fall = "fall"
        
        case stop = "Stop"
        case walkLeft = "walkLeft"
        case walkRight = "walkRight"
        
        case climbStop_Left = "ClimbStop Left"     //停止
        case climbUp_Left = "ClimbUP Left"          //登る
        case climbDown_Left = "ClimbDown Left"      //降りる
        case climbStop_Right = "ClimbStop Right"    //停止
        case climbUp_Right = "ClimbUP Right"        //登る
        case climbDown_Right = "ClimbDown Right"  //降りる

    }
    
   var ninjaState:State? = .fall
    var ninjaState_OLD:State! = .fall
    
    enum WallSide:String {
        case TOP = "TOP"
        case UNDER = "UNDER"
        case SIDE = "SIDE"
    
    }
    
    let ninjaCategory:UInt32        = 0x1 << 1      //0001
    let wallCategory:UInt32         = 0x1 << 2      //0010
    let groundCategory:UInt32       = 0x1 << 3      //0100
    let gameoverLineCategory:UInt32 = 0x1 << 4      //1000
    
//MARK:-

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
            SKTexture(imageNamed: "climb_L2.png"),
            SKTexture(imageNamed: "climb_L3.png"),
            SKTexture(imageNamed: "climb_L2.png")
        ]
        ninjaTex_Climb_R = [
            SKTexture(imageNamed: "climb_R1.png"),
            SKTexture(imageNamed: "climb_R2.png"),
            SKTexture(imageNamed: "climb_R3.png"),
            SKTexture(imageNamed: "climb_R2.png")
            
        ]
    //Power Level
        make_powerLevel()
        
    //ninja
        make_Ninja()
        
    }
    //MARK:-
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
    //MARK:テクスチャータイル作成
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

    //MARK:作成　壁
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
//MARK:-
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
            fallAction()
            
        default:
            println("\(__FUNCTION__) default")
            
        }
        
    }
    
    //MARK:忍者のアクションを削除
    func removeNinjaAction(){
        if ninja.hasActions() == true{
            ninja.removeAllActions()
            println("忍者アクション削除\(__FUNCTION__)")
        }
    }

    func fallAction(){
        
//        if ninjaState_OLD != .fall{
            switch touchState! {
            case .DOWN:
                println("ムササビの術")
            default:
                println(__FUNCTION__)
            ninjaState_OLD = .fall;println("落下中")
//            }
            
        }
    }
    
    //MARK:左の壁
    func climbAction_LeftWall(){
        switch touchState!{
            
        case .UP:

            //壁の高さチェック
            if ClimbingWall.UP != nil &&
                ClimbingWall.UP > ninja.position.y{
            
                if ninjaState_OLD != .climbUp_Left {
                    //他のアクションがあれば削除
                    removeNinjaAction()
                    
                    climbUP_LeftWall()
                    
                    ninjaState_OLD = .climbUp_Left
                }
            }else{
                println("これ以上登ることができません。")
                //他のアクションがあれば削除
                removeNinjaAction()
            }
            
            
        case .DOWN:
            //壁の高さチェック
            if ClimbingWall.DOWN != nil &&
                ClimbingWall.DOWN < ninja.position.y{
            
                if ninjaState_OLD != .climbDown_Left {
                    //他のアクションがあれば削除
                    removeNinjaAction()
                    
                    climbDown_LeftWall()
                    
                    ninjaState_OLD = .climbDown_Left
                }
            }else{
                println("これ以上降りることができません。")
                //他のアクションがあれば削除
                removeNinjaAction()
            }
        case .Neutral:
            
            if ninjaState_OLD != .climbStop_Left {
                removeNinjaAction()
                
                ninja.physicsBody?.dynamic = false;println("忍者の重力無効")
                println("左壁に停止")
                ninjaState_OLD = .climbStop_Left
                
            }
            
        case .Release:
        
            if ninjaState_OLD != .fall {
                removeNinjaAction()
                
                ninja.physicsBody?.dynamic = true;println("忍者の重力有効")
                println("左壁から落下")
                ninjaState_OLD = .fall; println("ninjaState fall")
                
            }
            
        default:
            println("\(__FUNCTION__) default")
            removeNinjaAction()
            ninja.physicsBody?.dynamic = false;println("忍者の重力無効")
            println("左壁に停止")
            ninjaState_OLD = .climbStop_Left
            

        }
    }
    
    
//MARK:右の壁
    func climbAction_RightWall(){
        switch touchState!{
            
        case .UP:
            
            //壁の高さチェック
            if ClimbingWall.UP != nil &&
                ClimbingWall.UP > ninja.position.y{
                    
                    if ninjaState_OLD != .climbUp_Right{
                        
                        //他のアクションがあれば削除
                        removeNinjaAction()
                        
                        climbUp_RightWall()
                        
                        ninjaState_OLD = .climbUp_Right;
                    }
            }else{
                println("これ以上登ることができません。")
                //他のアクションがあれば削除
                removeNinjaAction()
            }
            
            
        case .DOWN:
            //壁の高さチェック
            if ClimbingWall.DOWN != nil &&
                ClimbingWall.DOWN < ninja.position.y{
                    
                    if ninjaState_OLD != .climbDown_Right{
                        //他のアクションがあれば削除
                        removeNinjaAction()
                        
                        climbDown_RightWall()
                        
                        ninjaState_OLD = .climbDown_Right;
                    }
            }else{
                println("これ以上降りることができません。")
                //他のアクションがあれば削除
                removeNinjaAction()
                
            }
            
        case .Neutral:
          
            if ninjaState_OLD != .climbStop_Right {
                removeNinjaAction()
                
                 ninja.physicsBody?.dynamic = false
                ninjaState_OLD = .climbStop_Right;println("右壁に停止")
                
            }
            
        case .Release:
            //ninjaState = .climbStop_Right
            if ninjaState_OLD != .fall {
                removeNinjaAction()
                ninja.physicsBody?.dynamic = true
                println("右壁から落下する")
                ninjaState_OLD = .fall; println("ninjaState fall")
            }
            
        default:
            println("\(__FUNCTION__) default")
            removeNinjaAction()
            
            ninja.physicsBody?.dynamic = false
            ninjaState_OLD = .climbStop_Right;println("右壁に停止")
        }

    }
    
//    func walk_Left(){
//        
//        println("左へ歩く")
//        let move = SKAction.moveBy(CGVector(dx: -30, dy: 0), duration: 0.4)
//        let animation = SKAction.animateWithTextures(ninjaTex_Walk_L, timePerFrame: 0.1)
//        let action = SKAction.group([move,animation])
//        ninja.runAction(SKAction.repeatActionForever(action))
//    }
//    
//    func walk_Right(){
//        println("右へ歩く")
//        let move = SKAction.moveBy(CGVector(dx: 30, dy: 0), duration: 0.4)
//        let animation = SKAction.animateWithTextures(ninjaTex_Walk_R, timePerFrame: 0.1)
//        let action = SKAction.group([move,animation])
//        ninja.runAction(SKAction.repeatActionForever(action))
//    }
    
    
//MARK:歩く（地面）
    func walkAction(){
        switch touchState! {
        case .LEFT:
            
            if WalkingWallLimit.LEFT < ninja.position.x {
                if ninjaState_OLD != .walkLeft {
                    //他のアクションがあれば削除
                    removeNinjaAction()
 //                   println("touch LEFT")
                    
                    walkAction_Left()
                    ninjaState_OLD = .walkLeft
                }
            }else{
                //他のアクションがあれば削除
                removeNinjaAction()
                println("これ以上左へはいけません")
                ninja.texture = SKTexture(imageNamed:"ninja_front1.png")
                
                ninjaState_OLD = .stop
            }
    
        case .RIGHT:
            if WalkingWallLimit.RIGHT > ninja.position.x {
                if ninjaState_OLD != .walkRight {
                    //他のアクションがあれば削除
                    removeNinjaAction()
                    
//                    println("touch RIGHT")

                    walkAction_Right()
                    
                    ninjaState_OLD = .walkRight
                }
            }else{
                //他のアクションがあれば削除
                removeNinjaAction()
                println("これ以上右へはいけません")
                ninja.texture = SKTexture(imageNamed:"ninja_front1.png")
                
                ninjaState_OLD = .stop
            }
            
        case .Neutral:
            println("touch Neutral")
            
            if ninjaState_OLD != .stop {
                //他のアクションがあれば削除
                removeNinjaAction()
                
                ninja.texture = SKTexture(imageNamed:"ninja_front1.png")
                
                ninjaState_OLD = .stop
            }
            
        case .Release:
            
            if ninjaState_OLD != .stop {
                removeNinjaAction()
                
                ninja.texture = SKTexture(imageNamed:"ninja_front1.png")
                
                ninjaState_OLD = .stop
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
    
//MARK:-
//MARK:Jump method
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
    



    func jump(cgVector:CGVector){
        ninja.physicsBody?.dynamic = true
        
        
        
        if jumpTiming != nil {
            switch jumpTiming! {
            case .VeryFast:
                println("\(jumpTiming?.rawValue)")
//                ninja.physicsBody?.applyImpulse(CGVector(dx: 10, dy: 10))
            case .Fast:
                println("\(jumpTiming?.rawValue)")

            case .Best:
                println("\(jumpTiming?.rawValue)")

            case .Slow:
                println("\(jumpTiming?.rawValue)")

            case .VerySlow:
                println("\(jumpTiming?.rawValue)")

            default:
                println("\(jumpTiming?.rawValue)")
            }
        }else{
            ninja.physicsBody?.applyImpulse(CGVector(dx: 15, dy:15))

            
        }
        
        
//        ninja.physicsBody?.applyImpulse(cgVector)
        ninja.physicsBody?.applyImpulse(CGVector(dx: cgVector.dx, dy: 10))
//        ninja.physicsBody?.applyImpulse(CGVector(dx: 10, dy: 10))
        
        println("dy = \(cgVector.dy)")
        power = 0
        //タイミングの削除
        jumpTiming = nil; println("ジャンプタイミングチェック　終了")    }
    
    //== jump methed end ================

    //MARK:-
    //MARK:Walk Left method
    func walkAction_Left(){
        println("左へ歩く")
        let move = SKAction.moveBy(CGVector(dx: -30, dy: 0), duration: 0.4)
        let animation = SKAction.animateWithTextures(ninjaTex_Walk_L, timePerFrame: 0.1)
        let action = SKAction.group([move,animation])
        ninja.runAction(SKAction.repeatActionForever(action))
    }
    //MARK:Walk Right method
    func walkAction_Right(){
        println("右へ歩く")
        let move = SKAction.moveBy(CGVector(dx: 30, dy: 0), duration: 0.4)
        let animation = SKAction.animateWithTextures(ninjaTex_Walk_R, timePerFrame: 0.1)
        let action = SKAction.group([move,animation])
        ninja.runAction(SKAction.repeatActionForever(action))
    }
    
    //MARK:Climb UP LeftWall
    func climbUP_LeftWall(){
        
        println("左壁、登る")
        let move = SKAction.moveBy(CGVector(dx: 0, dy: 16), duration: 0.8)
        let animation = SKAction.animateWithTextures(ninjaTex_Climb_L, timePerFrame: 0.2)
        let action = SKAction.group([move,animation])
        ninja.runAction(SKAction.repeatActionForever(action))
    }
    
    func climbDown_LeftWall(){
        println("左壁、降りる")
        let move = SKAction.moveBy(CGVector(dx: 0, dy: -16), duration: 0.8)
        let animation = SKAction.animateWithTextures(ninjaTex_Climb_L, timePerFrame: 0.2)
        let action = SKAction.group([move,animation])
        ninja.runAction(SKAction.repeatActionForever(action))
        
    }
    
    func climbUp_RightWall(){
        println("右壁、登る")
        
        let move = SKAction.moveBy(CGVector(dx: 0, dy: 16), duration: 0.8)
        let animation = SKAction.animateWithTextures(ninjaTex_Climb_R, timePerFrame: 0.2)
        let action = SKAction.group([move,animation])
        ninja.runAction(SKAction.repeatActionForever(action))
    }
    
    func climbDown_RightWall(){
        println("右壁、降りる")
        
        let move = SKAction.moveBy(CGVector(dx: 0, dy: -16), duration: 0.8)
        let animation = SKAction.animateWithTextures(ninjaTex_Climb_R, timePerFrame: 0.2)
        let action = SKAction.group([move,animation])
        ninja.runAction(SKAction.repeatActionForever(action))
    }
    //MARK:-
    
    
    



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
            
//            // 原点からLimit以上動いた場合
//            if  beganPoint.y + limit <= location.y ||
//                beganPoint.y - limit >= location.y ||
//                beganPoint.x - limit >= location.x ||
//                beganPoint.x + limit <= location.x
//            {
//                touchState = .Neutral
//                return
//            }
            
                //Y判定
                if  beganPoint.y + add < location.y {
                    if touchState_OLD != TouchState.UP {
                            println("UP");myLabel.text = "↑"
                            touchState = .UP
                    }
                }else
                    if beganPoint.y - add > location.y{
                        if touchState_OLD != .DOWN{
                            println("DOWN");myLabel.text = "↓"
                           touchState = .DOWN
                        }
                }
                
        //X判定
                if  beganPoint.x - add > location.x {
                    if touchState_OLD != .LEFT{
                        println("LEFT");myLabel.text = "←"
                        touchState = .LEFT
                    }
                    
                }else
                    if beganPoint.x + add < location.x{
                        if touchState_OLD != .RIGHT{
                            
                            println("RIGHT");myLabel.text = "→"
                            touchState = TouchState.RIGHT
                        }
                }
//                if touchState_OLD != TouchState.Neutral {
//                    
//                    touchState = .Neutral; myLabel.text = "Neutral";println("Touch Neutral")
//                    
//                    touchState =  TouchState.Neutral
//                }
            
                
          //  }
        }
        touchState_OLD = touchState
    }
    
    //MARK:タッチ　終了
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        println(__FUNCTION__)
        _isTouchON = false;     println("タッチ解除")
        touchState = .Release;  myLabel.text = "Release";println("touch Release")
        
        if _isJumpTimingON{
            check_JumpTiming()
        }
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
        
//        if jumpTiming == nil {
//            
//        }


    }
//MARK:-
    
    
//MARK:xxx 衝突処理 xxx
    func didBeginContact(contact: SKPhysicsContact) {
        println(__FUNCTION__)
        let bodyA = contact.bodyA!
        let bodyB = contact.bodyB!
        
        func set_ClimbHeightLimit(){
//登れる高さのリミットを設定
//            println("bodyA  Height = \(bodyA.node!.frame.height)")
//            println("bodyA = posy \(bodyA.node!.position.y)")
//            println("ninja.posY = \(ninja.position.y)")
//            let down:CGFloat! = bodyA.node!.position.y
            
            ClimbingWall.DOWN = bodyA.node!.position.y + ninja.size.height / 2
            ClimbingWall.UP = bodyA.node!.frame.height + ClimbingWall.DOWN  - ninja.size.height / 2
            println("壁の上限 \(ClimbingWall.UP)、下限を設定\(ClimbingWall.DOWN)、忍者の位置\(ninja.position.y)")
            
        }
        
        //壁の左右のリミットを設定
        func set_ClimbWalkLimit(){
            WalkingWallLimit.LEFT = bodyA.node!.position.x - bodyA.node!.frame.size.width / 2
             WalkingWallLimit.RIGHT = bodyA.node!.position.x + bodyA.node!.frame.size.width / 2

            println("壁の左 \(WalkingWallLimit.LEFT )、右を設定\(WalkingWallLimit.RIGHT)、忍者の位置\(ninja.position.x)")
            // println("bodyB = \(bodyB.node?.frame.height)")
            
        }
        
        //

        func delete_ClimbHeightLimit(){
            println("壁の上限値、下限値　削除")
            ClimbingWall.DOWN = nil
            ClimbingWall.UP = nil
            WalkingWallLimit.LEFT = self.frame.origin.x
            WalkingWallLimit.RIGHT = self.frame.size.width
            println("壁の左 \(WalkingWallLimit.LEFT )、右を設定\(WalkingWallLimit.RIGHT)、忍者の位置\(ninja.position.x)")
        }
        
    //壁のどの面に当たったか？
        func wallHitCheck() -> WallSide{
            
            var wallSide:WallSide!
            //壁の下面より上にninja.position.y
            let under = bodyA.node!.position.y
            let top = bodyA.node!.frame.height + under
            
            //壁の上面より上にninja.position.y　地面
            if ninja.position.y > top{
                wallSide = .TOP
            }else if ninja.position.y < under {
                wallSide = .UNDER
            }else{
                wallSide = .SIDE
                _isJumpTimingON = true;println("ジャンプタイミングチェック　開始")
            }
            
            return wallSide
        }
       
        //ゲームオーバー用
        if bodyA.node?.name == "gameoverLine" || bodyB.node?.name == "gameoverLine"{
            println("game over")
            self.paused = true
            //delete_ClimbHeightLimit()
            
        }
        
        //地面
        if bodyA.node?.name == "ground"  || bodyB.node?.name == "ground"{
            println("地面にあたった")
            ninja.texture = SKTexture(imageNamed: "ninja_front1.png")
            ninjaState = .stop;     println("忍者スタータス　stop")
            touchState_OLD = .Neutral
            delete_ClimbHeightLimit()
        }else
        //左の壁
            if bodyA.node?.name == "wallLeft" || bodyB.node?.name == "wallLeft"{
                println("左の壁にあたった")
                //どの面に当たったか？
                let wallSide = wallHitCheck()
            
                switch wallSide {
                case .TOP:
                    println("左壁の上面にあたった")
                    set_ClimbWalkLimit()
                    ninja.texture = SKTexture(imageNamed: "ninja_front1.png")
                    ninjaState = .stop;     println("忍者スタータス　stop　左壁上面" )
                    ninja.physicsBody?.dynamic = true
                    

                case .UNDER:
                    println("壁の下面にあたった")
                    ninjaState = .fall
                    ninja.physicsBody?.dynamic = true
                    
                    
                case .SIDE:
                    //横面に当たった
                    ninja.texture = SKTexture(imageNamed: "climb_L1a.png")
                    ninjaState = .climbStop_Left;println("忍者スタータス　climbStop　左側")
                    set_ClimbHeightLimit()
                    ninja.physicsBody?.dynamic = false;println("忍者の重力無効")

                }
        }else
        //右の壁
            if bodyA.node?.name == "wallRight"  || bodyB.node?.name == "wallRight"{
                println("右の壁にあたった")
                 let wallSide = wallHitCheck()
                
                switch wallSide {
                case .TOP:
                    println("壁の上面にあたった")
                    set_ClimbWalkLimit() //歩ける壁の幅をしらべる
                    ninja.texture = SKTexture(imageNamed: "ninja_front1.png")
                    ninjaState = .stop;     println("忍者スタータス　stop　右壁上面")
                    ninja.physicsBody?.dynamic = true
                case .UNDER:
                    println("壁の下面にあたった")
                    ninjaState = .fall
                    ninja.physicsBody?.dynamic = true
                    
                    
                case .SIDE:
                    //横面に当たった
                ninja.texture = SKTexture(imageNamed: "climb_R1a.png")
                ninjaState = .climbStop_Right;println("忍者スタータス　climbStop　右側")
                set_ClimbHeightLimit()
                ninja.physicsBody?.dynamic = false ;println("忍者の重力なし")
                }
        }
     }
    
//MARK:-
    
    func physicsChange(){
        if ninja.physicsBody?.dynamic == true {
           ninja.physicsBody?.dynamic == false
            println("重力　無し")
        }else{
           ninja.physicsBody?.dynamic == true
            println("重力　有り")
            
        }
    }
    
    //MARK:アップデート
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */

        ninjaStateLabel.text = "\(ninjaState_OLD!.rawValue)"
        touchStateLabel.text = "\(touchState!.rawValue)"
        
        ninjaAction()
        
  //      disp_climingHeigth() //登った高さの表示
        
// 画面タッチ中　ーーーーーーーーーーーーーーーーーーーーーーーーー
        if _isTouchON && updateCount < powerMax{
            if ninjaState_OLD == State.stop ||
               ninjaState_OLD == State.climbStop_Left ||
               ninjaState_OLD == State.climbStop_Right
            {
            //ジャンプするパワー(タッチ中のアップデート回数）
            updateCount++
            jumpPowerFromUpdatecount()

            }
        }
        
// 画面タッチしてない　ーーーーーーーーーーーーーーーーーーーーーーーーー
        else{
                //　ジャンプパワーレベルを削除する
                delete_jumpPowerLevel()
        }
        
        if jumpTiming == nil{
            if _isJumpTimingON && jumpTimingCount < 30 {
                println(jumpTimingCount++)
            }else if jumpTimingCount == 30{
                jumpTimingCount = 0
                _isJumpTimingON = false;println("ジャンプタイミングチェック　終了")
                jumpTiming = .VerySlow
            }
        }
        
        
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
        
        disp_jumpPowerLevel()
    }
    
//MARK:ジャンプパワーレベルを表示する
    func disp_jumpPowerLevel(){
        if power > 0 {
            if updateCount <= powerMax{
                for i in 0..<updateCount {
                    //if powerLevel.count <= power {
                    powerLevel[i].hidden = false
                }
            }
        }
    }
    
    func delete_jumpPowerLevel(){
        for AnyObject in powerLevel {
            AnyObject.hidden = true
        }
        power = 0
    }
    
//MARK:ジャンプタイミング
    func check_JumpTiming(){
        
        println(__FUNCTION__)
        switch jumpTimingCount{
        case 0...5:
            jumpTiming = .VeryFast
            
        case 6...10:
            jumpTiming = .Fast
        case 11...20:
            jumpTiming = .Best
        case 21...30:
            jumpTiming = .Slow
//        case 21...25:
//            jumpTiming = .VerySlow
        default:
            println("")
        }
        _isJumpTimingON = false
        
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
