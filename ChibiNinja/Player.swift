//
//  Player.swift
//  ChibiNinja
//
//  Created by 義晴井上 on 2015/09/02.
//  Copyright (c) 2015年 tone.youring. All rights reserved.
//

import Foundation
import SpriteKit

enum State {
    case Nomal
    case WallLeft
    case WallRight
    case JumpLeft
    case JumpRight
    case Fall
    func texture() ->SKTexture{
        var tex = SKTexture()
        switch self{
        case .Nomal:
//            tex = SKTexture(imageNamed: "walk_L1")

            tex = SKTexture(imageNamed: "ninja_front1")
        case .WallLeft:
            tex = SKTexture(imageNamed: "climb_L1a.png")
        case .WallRight:
            tex = SKTexture(imageNamed: "climb_R1a.png")
        case .JumpLeft:
            tex = SKTexture(imageNamed: "jump_L.png")
        case .JumpRight:
            tex = SKTexture(imageNamed: "jump_R.png")
        case .Fall:
            tex = SKTexture(imageNamed: "ninja_front1.png")
            
//        default:
//            tex = SKTexture(imageNamed: "ninja_front1.png")
        }
     return tex
    }
    
}


class Player:Character {
    let nomalTexture = SKTexture(imageNamed: "ninja_front1.png")
    
    var jumpArrow = SKLabelNode(text: "↑")
    
    var _isJumpNow:Bool = true
      var state:State!
    
    init(){
        super.init(texture: nomalTexture, color: SKColor.clearColor(), size: nomalTexture.size())
        self.physicsBody =
            SKPhysicsBody(circleOfRadius: self.size.height / 3)
//        let size = CGSize(
//            width: self.size.width * 0.9,
//            height: self.size.height * 0.9)
//        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody?.restitution = 0.05 //跳ね返らない
        self.physicsBody?.friction = 1.0
        self.physicsBody?.allowsRotation = false //衝突で角度変化しない
        self.name = "player"
        self.direction = .Front
        self.state = .Nomal
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func jump(vector:CGVector){
        
        print("vector = \(vector)")
        
        if vector.dx < 0 {
            //左にジャンプ
            self.chenge_State(State.JumpLeft)
//            self.jumpAnimation(State.JumpLeft)
        }else{
            //右にジャンプ
            self.chenge_State(State.JumpRight)
//            self.jumpAnimation(State.JumpRight)
        }

        self.physicsBody?.velocity = vector
    }
   
    
    
    func change_Direction(newDirection:Direction){
        print(__FUNCTION__)
        if newDirection != self.direction{
            switch newDirection {
            case .Front:
                self.direction = .Front
            case .Left:
                self.direction = .Left
            case .Right:
                self.direction = .Right
            default:
                self.direction = .Back
            }
           self.chenge_Texture()
        }
    }
    
    func jumpAnimation(){
        switch self.state! {
        case .JumpLeft:
//            var pt = self.position
//            var vector = self.physicsBody?.velocity
//            var radian :CGFloat = atan2(
//                (pt.y + vector!.dy) - pt.y ,
//                (pt.x + vector!.dx) - pt.x)
//            self.zRotation = radian
        self.zRotation = 0
        case .JumpRight:
            let pt = self.position
            let vector = self.physicsBody?.velocity
            let radian :CGFloat = atan2(
                (pt.y + vector!.dy) - pt.y ,
                (pt.x + vector!.dx) - pt.x)
            self.zRotation = radian
        default:
            self.zRotation = 0
        }
        
    }
    
    //ステータスの変更があった場合は
    func chenge_State(newState:State){
        if self.state != newState {
            self.state = newState
            self.chenge_Texture()
        }
    }
    
    //テクスチャーを変更する
    func chenge_Texture(){
        print(__FUNCTION__)
        self.texture = self.state.texture()
    }
    
    


}