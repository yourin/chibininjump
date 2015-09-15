//
//  GameScene.swift
//  ChibiNinja
//
//  Created by 井上義晴 on 2015/03/24.
//  Copyright (c) 2015年 tone.youring. All rights reserved.
//

import SpriteKit

class GameScene: SKScene , SKPhysicsContactDelegate{
    
    let blockSize = CGSize(width: 32.0, height: 32.0)
    
    var _isDeBugMode    = true
    
    //判定
    
    var _isJump         = false
    var _isTouchON      = false
    
    var _gameoverFlg    = false
    
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
    
    //var tileTex:SKTexture!
    var ninja:SKSpriteNode!
    var aryMapChipTexture:TileMapMaker!
    
    
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
        case UP     = "UP"
        case DOWN   = "DOWN"
        case LEFT   = "LEFT"
        case RIGHT  = "RIGHT"
        case Neutral = "Neutral" //タッチしているが、beganPoint
    }
    var touchState:TouchState? = .Release
    var touchState_OLD:TouchState! = .Release
    
    enum State:String {
        
        case jump       = "Jump"
        case jumping    = "Jumping"
        case fall       = "fall"
        
        case stop       = "Stop"
        case walkLeft   = "walkLeft"
        case walkRight  = "walkRight"
        
        case climbStop_Left     = "ClimbStop Left"   //停止
        case climbUp_Left       = "ClimbUP Left"     //登る
        case climbDown_Left     = "ClimbDown Left"   //降りる
        case climbStop_Right    = "ClimbStop Right"  //停止
        case climbUp_Right      = "ClimbUP Right"    //登る
        case climbDown_Right    = "ClimbDown Right"  //降りる
    }
    
    var ninjaState:State?       = .fall
    var ninjaState_OLD:State!   = .fall
    
    enum WallSide:String {
        case TOP    = "TOP"
        case UNDER  = "UNDER"
        case SIDE   = "SIDE"
    }
    
    //MARK:衝突カテゴリ
    let ninjaCategory:UInt32        = 0x1 << 1      //0001
    let wallCategory:UInt32         = 0x1 << 2      //0010
    let groundCategory:UInt32       = 0x1 << 3      //0100
    let gameoverLineCategory:UInt32 = 0x1 << 4      //1000
    let wallLeftCategory:UInt32         = 0x1 << 10
    let wallRightCategory:UInt32         = 0x1 << 2
    
    //名前
    let kNinjaName      = "ninja"
    let kLeftWallName   = "leftwall"
    let kRightWallName  = "rightwall"
    let kGroundName     = "ground"
    let kGameOverLineName = "gameoverline"
    
//MARK:-

    func initSetting(){
        //画面の半分をスクロールする基準とする
        scrollPoint = self.size.height / 2
        scrollSpeed = 1.0
    }
    
    
    //MARK:-
    override func didMoveToView(view: SKView) {
        //MARK:初期化処理
        self.initSetting()
        
        if _isDeBugMode {
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

        
        //背景色
        self.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
        //self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        self.physicsBody?.categoryBitMask = 0
        self.physicsBody?.contactTestBitMask = 0
        self.physicsBody?.collisionBitMask = 0
        
        //物理シミュレーション設定
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        self.physicsWorld.speed = 0.6
        self.physicsWorld.contactDelegate = self
        
        
        
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
        
        
//MARK:マップチップテクスチャー作成
        aryMapChipTexture = TileMapMaker(textureFileName: "map", numberOfColumns: 8, numberOfRows: 16)
        println("mapchip = \(aryMapChipTexture.mapChip.count)")
        
//MARK:地面の作成
        //地面のマップチップを並べる
        let ground = aryMapChipTexture.make_MapChipRow_OriginLeft(mapNum: 1, HorizontaCount: 10, physics: true)
        ground.name = kGroundName
        ground.physicsBody?.categoryBitMask  = groundCategory
        ground.physicsBody?.collisionBitMask = ninjaCategory
        ground.physicsBody?.contactTestBitMask = ninjaCategory
        
        wallBG.addChild(ground)
        println(ground)
        
// MARK:壁の作成
        
        var nextYpos:CGFloat = 0.0
        for i in 1...5 {
            let randH = arc4random_uniform(4)+1
            let randV = arc4random_uniform(4)+1
            let sprite = aryMapChipTexture.make_MapChipBlock_OriginLeft(mapNum: 2, HorizontaCount: randH, VerticalCount: randV, physicsType: .Edge)
            sprite.name = kLeftWallName
            
            sprite.position = CGPoint(x:0, y: nextYpos)
            
            sprite.physicsBody?.categoryBitMask = wallCategory
            
            wallBG.addChild(sprite)
            nextYpos = nextYpos + 32 * CGFloat(randV)
            println("nextYpos = \(nextYpos)")
            
        }
        
        //右の壁
        nextYpos = 0.0
        for i in 1...5 {
            let randH = arc4random_uniform(4)+1
            let randV = arc4random_uniform(4)+1
            let sprite = aryMapChipTexture.make_MapChipBlock_OriginRight(mapNum: 2, HorizontaCount: randH, VerticalCount: randV, physicsType: .Edge)
            
            sprite.name = kRightWallName
            
            println("\(i): \(randH) x \(randV)")
            
            sprite.position = CGPoint(x:self.size.width, y: nextYpos)
            //        sprite.position = center
            nextYpos = nextYpos + 32 * CGFloat(randV)
            println("nextYpos = \(nextYpos)")
            wallBG.addChild(sprite)
        }
        
        // joypad
        make_Joypad()
        // ninja
        make_Ninja()
        
        // Power Level
        make_powerLevel()
    }
    
    // MARK:-
    
    //MARK:- ジャンプパワー表示
    func make_powerLevel(){
        
//        for i in 0 ..< powerMax{
//            var sprite = SKSpriteNode()
//            if i < powerMin{
//                sprite = SKSpriteNode(color: SKColor.blueColor(), size: CGSize(width: 7, height: 12 + CGFloat(i * 2)))
//            }else if i < powerMid {
//                sprite = SKSpriteNode(color: SKColor.yellowColor(), size: CGSize(width: 7, height: 12 + CGFloat(i * 2)))
//            }else{
//                sprite = SKSpriteNode(color: SKColor.redColor(), size: CGSize(width: 7, height: 12 + CGFloat(i * 2)))
//                
//            }
//            
//            sprite.hidden = true
//            sprite.zPosition = 2
//            sprite.position = CGPoint(x: 20.0 + sprite.size.width * 2 * CGFloat(i), y: 10)
//            
//            scoreBG.addChild(sprite)
//            powerLevel.append(sprite)
//        }
        
    }
    
    //MARK:- ランダム値作成
    func randomXpos(x:UInt32) -> CGFloat{
        return CGFloat(arc4random_uniform(x))
    }
    
    func random_number(min:UInt32,max:UInt32) -> UInt32{
            return arc4random_uniform(max) + min
    }
    
    func random_X_Size(minWidth:UInt32,maxWidth:UInt32) -> CGFloat{
         let width = arc4random_uniform(maxWidth) + minWidth
        return CGFloat(width)
    }
    
    func random_Y_Size(minHeight:UInt32,maxHeight:UInt32) -> CGFloat{
        let height = arc4random_uniform(maxHeight) + minHeight
        return CGFloat(height)
    }
    
    func make_NinjaTexture(){
        //MARK:忍者テクスチャー準備
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

    }
    
    //MARK:プレイヤー作成
    func make_Ninja(){
        
        make_NinjaTexture()
        ninja = SKSpriteNode(texture: SKTexture(imageNamed: "ninja_front1.png"))
        
        ninja.setScale(2.0)
        ninja.position = CGPoint(x: self.size.width / 2, y: 200)

        ninja.name = kNinjaName
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
//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
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
    
    //落下中にレバー下を入力することでムササビの術発動

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
            
            
//                let dxPower = addPower * CGFloat(power)
//                let dyPower = addPower * CGFloat(power)
            let dxPower:CGFloat = 5.0
            let dyPower:CGFloat = 5.0
            let vector:CGVector = CGVector(dx: dxPower, dy: dyPower)
            
                // 忍者のX位置から、ジャンプ方向を決める
                if ninja.position.x >= self.size.width / 2{
                    
                // Left jump
                    ninjaAction_JumpLeft(vector)
//                    ninjaAction_JumpLeft(dxPower: dxPower, dyPower: dyPower)
                    
                }else{
                // Right jump
                    ninjaAction_JumpRight(dxPower: dxPower, dyPower: dyPower)
                }
          
        }
        
    }
    
//MARK:-
//MARK:Jump method
    //MARK:左ジャンプ
    func ninjaAction_JumpLeft(vector:CGVector){
        ninja.texture = SKTexture(imageNamed: "jump_L.png")
        
        //通常のジャンプ
        let action = SKAction.runBlock({
            self.jump(CGVector(dx:-vector.dx , dy: vector.dy))
        })
        
        ninja.runAction(action)
        
        println("\(vector)　でジャンプした！\(__FUNCTION__)")
        _isJump = true
        ninjaState_OLD = .jumping
        
    }
    
    func ninjaAction_JumpLeft(#dxPower:CGFloat,dyPower:CGFloat){
        
        ninja.texture = SKTexture(imageNamed: "jump_L.png")
        //通常のジャンプ
        let action = SKAction.runBlock({
            self.jump(CGVector(dx:-dxPower , dy: dyPower))
        })
        
        ninja.runAction(action)
        
        println("\(dyPower)　でジャンプした！\(__FUNCTION__)")
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
    
    //MARK:- ジョイパッド
    var joypad:SKSpriteNode!
    var joyball:SKShapeNode!
    func make_Joypad(){
        // joypad setting
        let joypad = SKSpriteNode()
        joypad.zPosition = 100
        let ballHeight:CGFloat = 10.0
        let joyColor = SKColor.redColor()
        
        // joyBall
        let joyball = SKShapeNode(circleOfRadius: ballHeight)
        joyball.fillColor = joyColor
        joyball.strokeColor = SKColor.clearColor()
        self.joyball = joyball
        self.addChild(joyball)
        hide_Joypad()
        
        return
        
        // JoyBall MoveingLimit Ring
        let joyballLimitRing = SKShapeNode(circleOfRadius: ballHeight * 2)
        joyballLimitRing.strokeColor = joyColor
        
        joyballLimitRing.addChild(joyball)
        joypad.addChild(joyballLimitRing)
        self.joypad = joypad
        self.addChild(self.joypad)

        //非表示
        hide_Joypad()

        
    }
    func disp_Joypad(location:CGPoint){
//        joypad.hidden = false
//        joypad.position = location
        
        joyball.hidden = false
        
    }
    func hide_Joypad(){
//        joypad.hidden = true
        joyball.hidden = true
        
    }
    
    func move_joypad(location:CGPoint){
        let add:CGFloat = 3.0 //誤差
        let limit:CGFloat = add - 1.0
        
        
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
        
        touchState_OLD = touchState
    }
    
    
    //MARK:-

    //MARK:タッチ　開始
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        _isTouchON = true; myLabel.text = "タッチ開始"
        touchState = .Neutral; println("Touch Neutral")
        println("タッチ開始")
            for touch in (touches as! Set<UITouch>) {
                let location = touch.locationInNode(self)
                //初期値設定
                beganPoint = location
                //ジョイパッドの表示
                disp_Joypad(location)
            }
    }
    //MARK:タッチ　移動
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
           
            move_joypad(location)
            
        }
    }
    
    //MARK:タッチ　終了
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        println(__FUNCTION__)
        
        hide_Joypad()
        _isTouchON = false;     println("タッチ解除")
        touchState = .Release;  myLabel.text = "Release";println("touch Release")
        
        //ジャンプ中じゃないことのチェック
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
        
    }
    
//MARK: - xxx 衝突処理 xxx
    func didBeginContact(contact: SKPhysicsContact) {
        println(__FUNCTION__)
        let bodyA = contact.bodyA!
        let bodyB = contact.bodyB!
        
        println("A = \(bodyA.node!.name),B = \(bodyB.node!.name)")
        
        //高さのリミット設定
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
        //リミットを削除
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
       
// 処理　///////////////////////////////////////////////////////
        //ゲームオーバー用
        if bodyA.node?.name == kGameOverLineName || bodyB.node?.name == kGameOverLineName {
            println("game over")
            self.paused = true
            //delete_ClimbHeightLimit()
            
        }
        
        //地面
        if bodyA.node?.name == kGroundName  || bodyB.node?.name == kGroundName{
            println("地面にあたった")
            ninja.texture = SKTexture(imageNamed: "ninja_front1.png")
            ninjaState = .stop;     println("忍者スタータス　stop")
            touchState_OLD = .Neutral
            delete_ClimbHeightLimit()
        }else
        //左の壁
            if bodyA.node?.name == kLeftWallName || bodyB.node?.name == kLeftWallName{
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
            if bodyA.node?.name == kRightWallName  || bodyB.node?.name == kRightWallName{
                println("右の壁にあたった")
                 let wallSide = wallHitCheck()
                
                switch wallSide {
                case .TOP:
                    println("壁の上面にあたった")
                    set_ClimbWalkLimit() //歩ける壁の幅をしらべる
                    ninja.texture = SKTexture(imageNamed: "ninja_front1.png")
                    ninjaState = .stop;println("忍者スタータス　stop　右壁上面")
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
    
    func physicsChange(){
        if ninja.physicsBody?.dynamic == true {
           ninja.physicsBody?.dynamic == false
            println("重力　無し")
        }else{
           ninja.physicsBody?.dynamic == true
            println("重力　有り")
            
        }
    }
    
    //MARK: - アップデート
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
//            updateCount++
//            jumpPowerFromUpdatecount()

            }
        }
        
// 画面タッチしてない　ーーーーーーーーーーーーーーーーーーーーーーーーー
        else{
                //　ジャンプパワーレベルを削除する
//                delete_jumpPowerLevel()
        }
        
        if jumpTiming == nil{
            if _isJumpTimingON && jumpTimingCount < 30 {
//                println(jumpTimingCount++)
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
        
//        disp_jumpPowerLevel()
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
        self.physicsWorld.speed = 0
        
    }
    
    

}
