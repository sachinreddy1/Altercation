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
    
    var sceneView:SCNView!
    
    var playButton:SKSpriteNode?
    var gameScene:SCNScene!
    var scrollingBG:ScrollingBackground?
    
    
    override func didMove(to view: SKView) {
        playButton = self.childNode(withName: "startButton") as? SKSpriteNode
        
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
//                let transition = SKTransition.fade(withDuration: 1)
//                gameScene = SCNScene(named: "art.scnassets/MainScene.scn")
//                self.view?.presentScene(gameScene, transition: transition)
                
                
                //sceneView = self.view as? SCNView
                gameScene = SCNScene(named: "art.scnassets/MainScene.scn")
                self.view?.presentScene(gameScene)
                //sceneView.scene = gameScene
                
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let scrollBG = self.scrollingBG {
            scrollBG.update(currentTime: currentTime)
        }
    }
}

