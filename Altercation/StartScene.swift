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

class StartScene: SKScene {
    
    var playButton:SKSpriteNode?
    var levelButton:SKSpriteNode?
    var gameScene:SKScene!
    var scrollingBG:ScrollingBackground?
    
    override func didMove(to view: SKView) {
        playButton = self.childNode(withName: "startButton") as? SKSpriteNode
        levelButton = self.childNode(withName: "levelButton") as? SKSpriteNode
        
        scrollingBG = ScrollingBackground.scrollingNodeWithImage(imageName: "loopBG", containerWidth: self.size.width)
        scrollingBG?.scrollingSpeed = 1.5
        scrollingBG?.anchorPoint = .zero
        
        self.addChild(scrollingBG!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            if node == playButton {                
                let transition = SKTransition.push(with: SKTransitionDirection.up, duration: 0.25)
                gameScene = SKScene(fileNamed: "MainMenuScene")
                gameScene.scaleMode = .aspectFill
                self.view?.presentScene(gameScene, transition: transition)
            }
            
            if node == levelButton {
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

