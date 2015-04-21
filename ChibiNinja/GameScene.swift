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
    
    var ninja:SKSpriteNode!
    
    var scoreBG = SKNode()//スコア用Node

    var myLabel:SKLabelNode!
    
    
    var tileTex:SKTexture!
    
    var _isJump = false
    var _isTouchON = false
    
    var _gameoverFlg = false
    
    var updateCount = 0

    var power = 0
    
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
    
    enum TouchState {
        case Release
        case UP
        case DOWN
        case LEFT
        case RIGHT
        case Neutral //タッチしているが、beganPoint
    }
    var touchState:TouchState = .Release
    var touchState_OLD:TouchState = .Release
    
    enum State {
        
        case jump
        case jumping
        case fall
        
        case stop
        case walkLeft
        case walkRight
        
        
        case climbStop_Left      //停止
        case climbUp_Left    //登る
        case climbDown_Left  //降りる
        case climbStop_Right//停止
        case climbUp_Right    //登る
        case climbDown_Right  //降りる

    }
    
    var ninjaState:State? = .fall
    var ninjaState_OLD:State? = .fall
    
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
        
       // make_box()
        
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
        
        for i in 0 ..< 15{
            let sprite = SKSpriteNode(color: SKColor.redColor(), size: CGSize(width: 7, height: 12 + CGFloat(i * 2)))
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
    
    
    func climbAction_LeftWall(){
        switch touchState{
            
        case .UP:
            ninjaState = .climbUp_Left
            if ninjaState_OLD != ninjaState {
                //他のアクションがあれば削除
                removeNinjaAction()
                
                println("登る")
                let move = SKAction.moveBy(CGVector(dx: 0, dy: 5), duration: 0.4)
                let animation = SKAction.animateWithTextures(ninjaTex_Climb_L, timePerFrame: 0.2)
                let action = SKAction.group([move,animation])
                ninja.runAction(SKAction.repeatActionForever(action))
                
                ninjaState_OLD = ninjaState
            }
            
            
        case .DOWN:
            ninjaState = .climbDown_Left
            if ninjaState_OLD != ninjaState {
                //他のアクションがあれば削除
                removeNinjaAction()
                
                println("降りる")
                let move = SKAction.moveBy(CGVector(dx: 0, dy: -5), duration: 0.4)
                let animation = SKAction.animateWithTextures(ninjaTex_Climb_L, timePerFrame: 0.2)
                
                let action = SKAction.group([move,animation])
                
                ninja.runAction(SKAction.repeatActionForever(action))
                
                ninjaState_OLD = ninjaState
            }
            
        case .Neutral:
            ninjaState = .climbStop_Left
            if ninjaState_OLD != ninjaState {
                removeNinjaAction()
                
                ninja.physicsBody?.dynamic = false
                println("耐える")
                
            }
        case .Release:
            ninjaState = .climbStop_Left
            if ninjaState_OLD != ninjaState {
                removeNinjaAction()
                
                ninja.physicsBody?.dynamic = true
                println("耐える")
                
            }
            
            
            
        default:
            println("")
            
        }
    }
    
    func climbAction_RightWall(){
        switch touchState{
            
        case .UP:
            ninjaState = .climbUp_Right
            if ninjaState_OLD != ninjaState {
                //他のアクションがあれば削除
                removeNinjaAction()
                
                println("登る")
                
                //                    println("右へ移動")
                let move = SKAction.moveBy(CGVector(dx: 0, dy: 5), duration: 0.4)
                let animation = SKAction.animateWithTextures(ninjaTex_Climb_L, timePerFrame: 0.2)
                
                let action = SKAction.group([move,animation])
                
                ninja.runAction(SKAction.repeatActionForever(action))
                
                ninjaState_OLD = ninjaState
            }
            
            
        case .DOWN:
            ninjaState = .climbDown_Right
            if ninjaState_OLD != ninjaState {
                //他のアクションがあれば削除
                removeNinjaAction()
                
                println("降りる")
                let move = SKAction.moveBy(CGVector(dx: 0, dy: -5), duration: 0.4)
                let animation = SKAction.animateWithTextures(ninjaTex_Climb_L, timePerFrame: 0.2)
                
                let action = SKAction.group([move,animation])
                
                ninja.runAction(SKAction.repeatActionForever(action))
                
                ninjaState_OLD = ninjaState
            }
            
        case .Neutral:
            ninjaState = .climbStop_Left
            if ninjaState_OLD != ninjaState {
                removeNinjaAction()
                
                println("耐える")
                 ninja.physicsBody?.dynamic = false
            }
            
        case .Release:
            ninjaState = .climbStop_Left
            if ninjaState_OLD != ninjaState {
                removeNinjaAction()
                
                ninja.physicsBody?.dynamic = true
                println("耐える")
            }

            
        default:
            println("")
        }

    }
    
    func walkAction(){
        switch touchState {
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
            
            ninjaState = .walkRight
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
                
                println("touch Release")
                
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
            println("なにもしない")
        }
    }
    
    //MARK:忍者アクション
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
            println("落下中")
        default:
            println("default")
            
        }
        
    }
    
//MARK:忍者のアクションを削除
    func removeNinjaAction(){
        println(__FUNCTION__)
        println(ninja.hasActions())
        if ninja.hasActions() == true{
            ninja.removeAllActions()
        }
    }
    
    func jumpAction(){
        
        if ninjaState != .jumping {
            
            if wallLeft.position.x  + wallLeft.size.width  / 2 + 5 <= ninja.position.x ||
                wallRight.position.x - wallRight.size.width / 2 - 5 >= ninja.position.x
            {
                
                let dxPower = 10 * CGFloat(power)
                let dyPower = 10 * CGFloat(power)
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
        
    }
    
    //MARK:左ジャンプ
    func ninjaAction_JumpLeft(#dxPower:CGFloat,dyPower:CGFloat){
        
        ninja.texture = SKTexture(imageNamed: "jump_L.png")
//        if power == 15 {
//            let action = SKAction.group([
//                SKAction.rotateByAngle(CGFloat(M_PI * 2), duration:0.8),
//                SKAction.moveBy(CGVector(dx:-dxPower , dy: dyPower), duration: 1)])
//            ninja.runAction(action)
//        }else{
            //通常のジャンプ
            //ninja.physicsBody?.applyImpulse(CGVector(dx:-dxPower , dy: dyPower))
            let action = SKAction.moveBy(CGVector(dx:-dxPower , dy: dyPower), duration: 1)
            ninja.runAction(action)
            
//        }
        println("\(power)　でジャンプした！")
        _isJump = true
        ninjaState = .jumping
        power = 0
        
    }


    //MARK:右ジャンプ
    func ninjaAction_JumpRight(#dxPower:CGFloat,dyPower:CGFloat){

        ninja.texture = SKTexture(imageNamed: "jump_R.png")
//        if power == 15 {
//            
//            let action = SKAction.group([
//                SKAction.rotateByAngle(CGFloat(M_PI * 2), duration:0.8),
//                SKAction.moveBy(CGVector(dx:dxPower , dy: dyPower), duration: 1)
//                ])
//            
//            ninja.runAction(action)
//        }else{
            //通常のジャンプ
           // ninja.physicsBody?.applyImpulse(CGVector(dx:dxPower , dy: dyPower))
            let action = SKAction.moveBy(CGVector(dx:dxPower , dy: dyPower), duration: 1)
            ninja.runAction(action)
//        }
        _isJump = true
        ninjaState = .jumping
        println("\(power)　でジャンプした！")
        power = 0
        
    }
    


    //MARK:タッチ　開始
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        //            println(__FUNCTION__)
        _isTouchON = true
        
//        touchState = TouchState.Neutral
    
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
            
            
            if  beganPoint.y + limit <= location.y || beganPoint.y - limit >= location.y ||
                beganPoint.x - limit >= location.x || beganPoint.x + limit <= location.x
            {
                if touchState != TouchState.Neutral {
                touchState = TouchState.Neutral
                println("ニュートラル")
                touchState_OLD = touchState
                
                }
            
            
            
        //Y判定
            if  beganPoint.y + add < location.y {
                touchState = TouchState.UP
                
                switch touchState{
                    
                case .UP:
                    ninjaState = .climbUp_Right
                    if ninjaState_OLD != ninjaState {
                        //他のアクションがあれば削除
                        removeNinjaAction()
                        
                        println("登る")
                        
                        //                    println("右へ移動")
                        let move = SKAction.moveBy(CGVector(dx: 0, dy: 5), duration: 0.4)
                        let animation = SKAction.animateWithTextures(ninjaTex_Climb_L, timePerFrame: 0.2)
                        
                        let action = SKAction.group([move,animation])
                        
                        ninja.runAction(SKAction.repeatActionForever(action))
                        
                        ninjaState_OLD = ninjaState
                    }
                    
                    
                case .DOWN:
                    ninjaState = .climbDown_Right
                    if ninjaState_OLD != ninjaState {
                        //他のアクションがあれば削除
                        removeNinjaAction()
                        
                        println("降りる")
                        let move = SKAction.moveBy(CGVector(dx: 0, dy: -5), duration: 0.4)
                        let animation = SKAction.animateWithTextures(ninjaTex_Climb_L, timePerFrame: 0.2)
                        
                        let action = SKAction.group([move,animation])
                        
                        ninja.runAction(SKAction.repeatActionForever(action))
                        
                        ninjaState_OLD = ninjaState
                    }
                    
                case .Neutral:
                    ninjaState = .climbStop_Left
                    if ninjaState_OLD != ninjaState {
                        removeNinjaAction()
                        
                        println("耐える")
                        
                    }
                default:
                    println("")
                }
if touchState_OLD == touchState{
                    return
                }
                println("UP")
                myLabel.text = "↑"
                
                
            }else if    beganPoint.y - add > location.y{
                touchState = TouchState.DOWN
                if touchState_OLD == touchState{
                    return
                }
                println("DOWN")
                myLabel.text = "↓"
            }
                
            
        //X判定
            if          beganPoint.x - add > location.x {
                touchState = TouchState.LEFT
                if touchState_OLD == touchState{
                    return
                }
                println("LEFT")
                myLabel.text = "←"
                
            }else if    beganPoint.x + add < location.x{
                
                touchState = TouchState.RIGHT
                if touchState_OLD == touchState{
                    return
                }
                println("RIGHT")
                myLabel.text = "→"
                
            }

            }
        }
                touchState_OLD = touchState
    }
    
    //MARK:タッチ　終了
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        println(__FUNCTION__)
        
        if ninjaState_OLD != nil{
            switch ninjaState_OLD! {
            case .stop:
                ninjaState = .jump
            case .climbStop_Left:
                ninjaState = .jump
            case .climbStop_Right:
                ninjaState = .jump
            default:
                println("なにもしない")
                
            }
        }
        println("タッチ解除")
        beganPoint = nil
        _isTouchON = false
        updateCount = 0
//        power = 0
        touchState = .Release
        myLabel.text = "Release"
    }
    
   //MARK:衝突処理
    func didBeginContact(contact: SKPhysicsContact) {
        println(__FUNCTION__)
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
       // ninja.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 0))
        
        if bodyA.node?.name == "gameoverLine" || bodyB.node?.name == "gameoverLine"{
            println("game over")
            self.paused = true
        }
        
//        if _isTouchON {
            if bodyA.node?.name == "wallLeft" || bodyB.node?.name == "wallLeft"{
                println("左の壁")
               // ninja.physicsBody?.dynamic = false
                ninja.texture = SKTexture(imageNamed: "climb_L1a.png")
                ninjaState = .climbStop_Left
                println("忍者スタータス　climbStop　左側")
                
        }
            
            if bodyA.node?.name == "wallRight"  || bodyB.node?.name == "wallRight"{
                println("右の壁")
               // ninja.physicsBody?.dynamic = false
                ninja.texture = SKTexture(imageNamed: "climb_R1a.png")
                ninjaState = .climbStop_Right
        println("忍者スタータス　climbStop　右側")
        }
            if bodyA.node?.name == "ground"  || bodyB.node?.name == "ground"{
                println("地面")
                ninja.texture = SKTexture(imageNamed: "ninja_front1.png")
                ninjaState = .stop
                println("忍者スタータス　stop")
            }
            
//        }
        if _isJump {
            _isJump = false
            
            println("ジャンプ終わり")
        }
        println("ninjaPosY = \(ninja.position.y)")
        
        //ninja.physicsBody?.dynamic = false
    }
    //
    func jumpPowerFromUpdatecount(){
      
        switch updateCount {
        case 0...14:
            power = updateCount
        case 15...20:
            power = 15
        default:
            power = 10
        }
        println("power = \(power)")
        disp_jumpPowerLevel()
    }
    
    //　ジャンプパワーレベルを表示する
    func disp_jumpPowerLevel(){
        
        for i in 0..<power {
            //if powerLevel.count <= power {
            powerLevel[i].hidden = false
        }
    }
    
    func disp_climingHeigth(){
        let climingHeight = Int(ninja.position.y / ninja.size.height)
        myLabel.text = "\(climingHeight) m"
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        ninjaAction()
        
  //      disp_climingHeigth() //登った高さの表示
        
// 画面タッチ中　ーーーーーーーーーーーーーーーーーーーーーーーーー
        if _isTouchON {
            
            if ninjaState_OLD == .stop ||
                ninjaState_OLD == .climbStop_Left || ninjaState_OLD == .climbStop_Right ||
                ninjaState_OLD == .jump
            {
                //ジャンプするパワー(タッチ中のアップデート回数）
                updateCount++
                jumpPowerFromUpdatecount()
            }
        }
// 画面タッチしてない　ーーーーーーーーーーーーーーーーーーーーーーーーー
        else{
//            updateCount = 0
//            power = 0
        }
        
        //　ジャンプパワーレベルを削除する
        if power == 0 {
            for sprite in powerLevel {
                sprite.hidden = true
            }
        }
        
// 画面半分を超えたらスクロールを開始する　-------
        if ninja.position.y > scrollPoint{
            
            let moveY = ninja.position.y - scrollPoint
        
        wallBG.position = CGPoint(x: wallBG.position.x, y: wallBG.position.y - moveY)
            scrollPoint = scrollPoint + moveY
            
        }

// -----------------------------------------
        if ninja.hasActions(){
//println("忍者アクション実行中")

}else{
//println("忍者はアクションしていない")
}

    }
    
    func gameover(){
        self.physicsWorld.speed = 0;
        
    }
    
    

}
