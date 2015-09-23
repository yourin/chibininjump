//
//  GameViewController.swift
//  ChibiNinja
//
//  Created by 井上義晴 on 2015/03/24.
//  Copyright (c) 2015年 tone.youring. All rights reserved.
//

import UIKit
import SpriteKit


//extension SKNode {
//    class func unarchiveFromFile(file : NSString) -> SKNode? {
//        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
//            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
//            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
//            
//            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
//            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
//            archiver.finishDecoding()
//            return scene
//        } else {
//            return nil
//        }
//    }
//}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let scene = GameScene3()
        
        let skView = self.view as! SKView
        
            skView.showsFPS = true
            skView.showsNodeCount = true
       

            if #available(iOS 8.0, *) {
                skView.showsPhysics = true
            } else {
                // Fallback on earlier versions
            }
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
        
        //MARK:
        var gameSize = CGSize()
        gameSize.width = 160//320
        if skView.frame.size.height > 480 {
            //iPhone5以降
            gameSize.height = 284// 568;
        } else {
            //iPhone4s
            gameSize.height = 240//480;
        }
        
            scene.size = gameSize
            //scene.size = skView.frame.size
            skView.presentScene(scene)
//        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }


//    override func supportedInterfaceOrientations() -> Int {
//        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
//            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
//        } else {
//            return Int(UIInterfaceOrientationMask.All.rawValue)
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
