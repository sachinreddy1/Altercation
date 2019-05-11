//
//  StartScene.swift
//  Altercation
//
//  Created by Sachin Reddy on 5/3/19.
//  Copyright © 2019 Sachin Reddy. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit

class MainMenuScene: SKScene {
    
    var playButton:SKSpriteNode?
    var gameScene:SCNScene!
    var scrollingBG:ScrollingBackground?
    
    override func didMove(to view: SKView) {        
        playButton = self.childNode(withName: "levelButton") as? SKSpriteNode
        
        scrollingBG = ScrollingBackground.scrollingNodeWithImage(imageName: "loopBG", containerWidth: self.size.width)
        scrollingBG?.scrollingSpeed = 1.5
        scrollingBG?.anchorPoint = .zero
        
        self.addChild(scrollingBG!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            print(pos, node)
            if node == playButton {
                
                let vc = self.view?.window?.rootViewController!;
                vc?.performSegue(withIdentifier: "id2", sender: nil)
                
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let scrollBG = self.scrollingBG {
            scrollBG.update(currentTime: currentTime)
        }
    }
}

