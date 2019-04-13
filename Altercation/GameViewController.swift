//
//  GameViewController.swift
//  Altercation
//
//  Created by Sachin Reddy on 4/6/19.
//  Copyright © 2019 Sachin Reddy. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit

class GameViewController: UIViewController {
    
    let CategoryTree = 2
    var sceneView:SCNView!
    var scene:SCNScene!
    var ballNode:SCNNode!
    var selfieStickNode:SCNNode!
    
    var motion = MotionHelper()
    var motionForce = SCNVector3(0, 0, 0)
    var sounds:[String:SCNAudioSource] = [:]
    
    /* ---------------------------------------------------- */
    
    lazy var skView: SKView = {
        let view = SKView()
        view.isMultipleTouchEnabled = true
        view.backgroundColor = .clear
        view.isHidden = false
        return view
    }()
    
    /* --------------------------------------------------------- */
    /* viewDidLoad: Runs the operations to load scene, nodes, and
                    sounds                                       */
    /* --------------------------------------------------------- */
    override func viewDidLoad() {
        setupScene()
        setupNodes()
        setupSounds()
        setupSKView()
        setupSKViewScene()
        
        /*
        NotificationCenter.default.addObserver(forName: joystickNotificationName, object: nil, queue: OperationQueue.main) { (notification) in
            guard let userInfo = notification.userInfo else { return }
         
            let data = userInfo["data"] as! AnalogJoystickData
            
            //print(data.description)
            
            self.hero.position = SCNVector3(self.hero.position.x + Float(data.velocity.x * joystickVelocityMultiplier), self.hero.position.y, self.hero.position.z - Float(data.velocity.y * joystickVelocityMultiplier))
        
            self.hero.eulerAngles.y = Float(data.angular) + Float(180.0.degreesToRadians)
        }
        */
    }
    
    /* --------------------------------------------------------- */
    /* setupScene: Sets up the scene                             */
    /* --------------------------------------------------------- */
    func setupScene(){
        sceneView = self.view as? SCNView
        sceneView.delegate = self
        
        //sceneView.allowsCameraControl = true
        scene = SCNScene(named: "art.scnassets/MainScene.scn")
        sceneView.scene = scene
        
        scene.physicsWorld.contactDelegate = self
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        
        tapRecognizer.addTarget(self, action: #selector(GameViewController.sceneViewTapped(recognizer:)))
        sceneView.addGestureRecognizer(tapRecognizer)
    }
    
    func setupNodes() {
        ballNode = scene.rootNode.childNode(withName: "ball", recursively: true)!
        ballNode.physicsBody?.contactTestBitMask = CategoryTree
        selfieStickNode = scene.rootNode.childNode(withName: "selfieStick", recursively: true)!
    }
    
    func setupSounds() {
        let sawSound = SCNAudioSource(fileNamed: "chainsaw.wav")!
        let jumpSound = SCNAudioSource(fileNamed: "jump.wav")!
        sawSound.load()
        jumpSound.load()
        sawSound.volume = 0.3
        jumpSound.volume = 0.4
        
        sounds["saw"] = sawSound
        sounds["jump"] = jumpSound
    }
    
    /* --------------------------------------------------------- */
    
    func setupSKView() {
        view.addSubview(skView)
        skView.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 180)
    }
    
    func setupSKViewScene() {
        let scene = ARJoystickSKScene(size: CGSize(width: view.bounds.size.width, height: 180))
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        //    skView.showsFPS = true
        //    skView.showsNodeCount = true
        //    skView.showsPhysics = true
    }
    
    /* --------------------------------------------------------- */
    /* sceneViewTapped: If sceneView is tapped                   */
    /* --------------------------------------------------------- */
    @objc func sceneViewTapped (recognizer:UITapGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(location, options: nil)
        
        if hitResults.count > 0 {
            let result = hitResults.first
            if let node = result?.node {
                if node.name == "ball" {
                    let jumpSound = sounds["jump"]!
                    ballNode.runAction(SCNAction.playAudio(jumpSound, waitForCompletion: false))
                    ballNode.physicsBody?.applyForce(SCNVector3(x: 0, y:4, z: -2), asImpulse: true)
                }
            }
        }
    }
    
    /* --------------------------------------------------------- */
        
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}

/* --------------------------------------------------------- */
/* renderer:                                                 */
/* --------------------------------------------------------- */
extension GameViewController : SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let ball = ballNode.presentation
        let ballPosition = ball.position
        
        let targetPosition = SCNVector3(x: ballPosition.x, y: ballPosition.y + 5, z:ballPosition.z + 5)
        var cameraPosition = selfieStickNode.position
        
        let camDamping:Float = 0.3
        
        let xComponent = cameraPosition.x * (1 - camDamping) + targetPosition.x * camDamping
        let yComponent = cameraPosition.y * (1 - camDamping) + targetPosition.y * camDamping
        let zComponent = cameraPosition.z * (1 - camDamping) + targetPosition.z * camDamping
        
        cameraPosition = SCNVector3(x: xComponent, y: yComponent, z: zComponent)
        selfieStickNode.position = cameraPosition
        
        /* --------------------------------------------------------- */
        NotificationCenter.default.addObserver(forName: joystickNotificationName, object: nil, queue: OperationQueue.main) { (notification) in
            guard let userInfo = notification.userInfo else { return }
            
            let data = userInfo["data"] as! AnalogJoystickData
            
            self.motionForce = SCNVector3(x: Float(data.velocity.x * joystickVelocityMultiplier), y:0, z: -Float(data.velocity.y * joystickVelocityMultiplier))
        }
        ballNode.physicsBody?.velocity += motionForce
        
    }
}

/* --------------------------------------------------------- */
/* physicsWorld:                                             */
/* --------------------------------------------------------- */
extension GameViewController : SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var contactNode:SCNNode!
        
        if contact.nodeA.name == "ball" {
            contactNode = contact.nodeB
        }else{
            contactNode = contact.nodeA
        }
        
        if contactNode.physicsBody?.categoryBitMask == CategoryTree {
            contactNode.isHidden = true
            
            let sawSound = sounds["saw"]!
            ballNode.runAction(SCNAction.playAudio(sawSound, waitForCompletion: false))
            
            let waitAction = SCNAction.wait(duration: 15)
            let unhideAction = SCNAction.run { (node) in
                node.isHidden = false
            }
            
            let actionSequence = SCNAction.sequence([waitAction, unhideAction])
            
            contactNode.runAction(actionSequence)
        }
        
    }
}
