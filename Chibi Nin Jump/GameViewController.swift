//
//  GameViewController.swift
//  Chibi Nin Jump
//
//  Created by 義晴井上 on 2015/09/27.
//  Copyright (c) 2015年 youringtone. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene()
        
        let skView = self.view as! SKView
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        skView.showsNodeCount = true
        
        
        skView.showsFields = true
        skView.showsQuadCount = true
        
        skView.showsPhysics = true
        
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

//        if let scene = GameScene(fileNamed:"GameScene") {
//            // Configure the view.
//            let skView = self.view as! SKView
//            skView.showsFPS = true
//            skView.showsNodeCount = true
//            
//            /* Sprite Kit applies additional optimizations to improve rendering performance */
//            skView.ignoresSiblingOrder = true
//            
//            /* Set the scale mode to scale to fit the window */
//            scene.scaleMode = .AspectFill
//            
//            skView.presentScene(scene)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
