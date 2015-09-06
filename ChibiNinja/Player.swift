//
//  Player.swift
//  ChibiNinja
//
//  Created by 義晴井上 on 2015/09/02.
//  Copyright (c) 2015年 tone.youring. All rights reserved.
//

import Foundation
import SpriteKit

class Player:Character {
    let nomalTexture = SKTexture(imageNamed: "ninja_front1.png")
    
    var jumpArrow = SKLabelNode(text: "↑")
    
    var _isJumpNow:Bool = false
    
    init(){
        super.init(texture: nomalTexture, color: SKColor.clearColor(), size: nomalTexture.size())
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height / 2)
//        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.restitution = 0.0 //跳ね返らない
        self.physicsBody?.allowsRotation = false //衝突で角度変化しない
        self.name = "player"
        self.direction = .Front
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
    
    func chenge_Texture(){
        println(__FUNCTION__)
    }


}