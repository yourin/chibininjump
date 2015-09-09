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
            tex = SKTexture(imageNamed: "ninja_front1.png")
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
            
        default:
            tex = SKTexture(imageNamed: "ninja_front1.png")
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
        self.physicsBody = SKPhysicsBody(
            circleOfRadius: self.size.height / 2)
//        let size = CGSize(
//            width: self.size.width * 0.9,
//            height: self.size.height * 0.9)
//        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody?.restitution = 0.0 //跳ね返らない
        self.physicsBody?.allowsRotation = false //衝突で角度変化しない
        self.name = "player"
        self.direction = .Front
        self.state = .Nomal
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func jump(vector:CGVector){
        self.physicsBody?.velocity = vector
    }
    
    func change_Direction(newDirection:Direction){
        println(__FUNCTION__)
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
    
    func chenge_State(newState:State){
        if self.state != newState {
            self.state = newState
            self.chenge_Texture()
        }
    }
    
    
    func chenge_Texture(){
        println(__FUNCTION__)
        self.texture = self.state.texture()
    }


}