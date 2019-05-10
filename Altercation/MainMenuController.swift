//
//  MainMenuController.swift
//  Altercation
//
//  Created by Sachin Reddy on 5/10/19.
//  Copyright © 2019 Sachin Reddy. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit

class MainMenuController: UIViewController {
    
    override func viewDidLoad() {
        setupScene()
    }
    
    func setupScene(){
        super.viewDidLoad()
        
        if let view = self.view as? SKView {
            if let scene = SKScene(fileNamed: "MainMenuScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
