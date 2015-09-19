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
    var minimumAngle:Double!
    var maximumAngle:Double!
    
    override init(){
        super.init()
        self.text = "↑"
        self.fontSize = 15
        self.fontColor = UIColor.redColor()
        self.alpha = 0.5
        self.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        self.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Bottom
        
        self.minimumAngle = 0.0
        self.maximumAngle = 360.0
//        set_rotation(minAngle: 0, maxAngle: 360)
//        let timer = NSTimer.scheduledTimerWithTimeInterval(1/30, target: self, selector: "update", userInfo: nil, repeats: true)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //時計の文字盤の角度指定ができる
//    func clockAngle(#directionTime:Int) -> Double{
//        switch directionTime {
//        
//        
//        
//        case 0...5:
//            print()
//            
//        case 7...11:
//            return 180
//            
//        default:print("")
//            
//        }
        
//    }
    
    func durationTime() -> NSTimeInterval{
        var max = self.maximumAngle
        var min = self.minimumAngle
        if max < min {
            min = self.maximumAngle
            max = self.minimumAngle
        }
        print("max = \(max),min = \(min)")
        print("durationTime = \(NSTimeInterval((max - min) / 90))")
        return NSTimeInterval((max - min) / 180)
    }
   
    func set_Rotation(){
        self.zRotation = DegreeToRadian(self.minimumAngle)
        
        let action = SKAction.sequence([
            
            SKAction.rotateToAngle(DegreeToRadian(self.minimumAngle), duration: durationTime()),
            SKAction.rotateToAngle(DegreeToRadian(self.maximumAngle), duration: durationTime())
            ])
  
        action.timingMode = SKActionTimingMode.EaseInEaseOut
        self.runAction(SKAction.repeatActionForever(action))

        
    }
    
    func set_Rotation(minAngle minAngle:Double,maxAngle:Double){
        if self.hasActions(){
            self.removeAllActions()
        }
        
        self.minimumAngle = minAngle
        self.maximumAngle = maxAngle
        
        self.zRotation = DegreeToRadian(minAngle)
        
        let action = SKAction.sequence([
            
            SKAction.rotateToAngle(DegreeToRadian(minAngle), duration: durationTime()),
            SKAction.rotateToAngle(DegreeToRadian(maxAngle), duration: durationTime())

            ])
        action.timingMode = SKActionTimingMode.EaseInEaseOut
        self.runAction(SKAction.repeatActionForever(action))
    }
    
    func update(){
        print("角度　＝　\(RadianToDegree(self.zRotation))")
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
        
        let v = CGVector(dx:power * -x, dy:power * y)
        print(__FUNCTION__ ," \(v)")
        
        return CGVector(dx:power * -x, dy:power * y)
        
    
    }
    
    
}
