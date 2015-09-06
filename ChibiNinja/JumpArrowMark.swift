//
//  JumpArrowMark.swift
//  ChibiNinja
//
//  Created by 義晴井上 on 2015/09/02.
//  Copyright (c) 2015年 tone.youring. All rights reserved.
//

import Foundation
import SpriteKit

class JumpArrowMark:SKLabelNode {
    
    var arrowDuration:NSTimeInterval = 1.0
    var action:SKAction?
    
    override init(){
        super.init()
        self.text = "↑"
        self.fontSize = 30
        self.fontColor = UIColor.redColor()
        self.alpha = 0.5
        self.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        self.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Bottom
        
//        set_rotation(minAngle: 0, maxAngle: 360)
//        let timer = NSTimer.scheduledTimerWithTimeInterval(1/30, target: self, selector: "update", userInfo: nil, repeats: true)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //時計の文字盤の角度指定ができる
    func clockAngle(startTime:Int,endTime:Int){
        
        
        
        
        
    }
    
    
    func set_rotation(#minAngle:Double,maxAngle:Double){
        self.zRotation = DegreeToRadian(minAngle)
        
        let action = SKAction.sequence([
            
            SKAction.rotateToAngle(DegreeToRadian(minAngle), duration: arrowDuration),
            SKAction.rotateToAngle(DegreeToRadian(maxAngle), duration: arrowDuration)

            ])
        action.timingMode = SKActionTimingMode.EaseInEaseOut
        self.runAction(SKAction.repeatActionForever(action))
    }
    
    func update(){
        println("角度　＝　\(RadianToDegree(self.zRotation))")
    }
    
    /*
    度数からラジアンに変換するメソッド
    */
    func DegreeToRadian(Degree : Double!)-> CGFloat{
        return CGFloat(Degree) / CGFloat(180.0 * M_1_PI)
    }
    
    //ラジアンから度数に変換するメソッド
    
    func RadianToDegree(Radian : CGFloat)-> CGFloat{
      return Radian * CGFloat(180.0 * M_1_PI)
    }

    //角度と距離から座標を求める
    func jumpVector() -> CGVector{
        let x = sin(self.zRotation)
        let y = cos(self.zRotation)
        let power:CGFloat = 500.0
        return CGVector(dx:power * -x, dy:power * y)
    
    }
    
    
}
