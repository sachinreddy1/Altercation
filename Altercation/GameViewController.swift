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
import GameplayKit

class GameViewController: UIViewController {
    
    let CategoryTree = 2
    var sceneView:SCNView!
    var scene:SCNScene!
    var ballNode:SCNNode!
    var selfieStickNode:SCNNode!
    
    var motion = MotionHelper()
    var motionForce = SCNVector3(0, 0, 0)
    var theta = Float(0)
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
        setupStartScene()
//        setupScene()
//        setupNodes()
//        setupSounds()
//        setupSKView()
//        setupSKViewScene()
    }
    
    func setupStartScene(){
        super.viewDidLoad()
        if let view = self.view as? SKView {
            if let scene = SKScene(fileNamed: "StartScene") {
                print("scene obtained ")
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
        else {
            print("scene not obtained ")
        }
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
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.showsPhysics = true
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
        
        /* --------------------------------------------------------- */
        /* Calculating camera position                               */
        /* --------------------------------------------------------- */
        var cameraPosition = self.selfieStickNode.position
        var x_ = 4 * sin(self.theta * Float.pi/180)
        var z_ = 4 * cos(self.theta * Float.pi/180)
        
        NotificationCenter.default.addObserver(forName: camera_joystickNotificationName, object: nil, queue: OperationQueue.main) { (notification) in
            guard let userInfo = notification.userInfo else { return }
            let data = userInfo["data"] as! AnalogJoystickData

            cameraPosition = self.selfieStickNode.position
            /* --------------------------------------------------------- */
            /* Panning and rotating the camera: y-axis */
            /* --------------------------------------------------------- */
            self.theta += Float(data.velocity.x * rotatejoystickVelocityMultiplier)
            x_ = 4 * sin(self.theta * Float.pi/180)
            z_ = 4 * cos(self.theta * Float.pi/180)
            if (self.theta >= 360 || self.theta <= -360) { self.theta = 0}
            
            cameraPosition = SCNVector3(x: ballPosition.x + x_, y: cameraPosition.y, z: ballPosition.z + z_)
            do {
                self.selfieStickNode.eulerAngles = SCNVector3(-30 * Float.pi/180, self.theta * Float.pi/180, 0)
                self.selfieStickNode.position = cameraPosition
                self.selfieStickNode.eulerAngles = SCNVector3(-30 * Float.pi/180, self.theta * Float.pi/180, 0)
            }
        }
        do {
            self.selfieStickNode.eulerAngles = SCNVector3(-30 * Float.pi/180, self.theta * Float.pi/180, 0)
            self.selfieStickNode.position = SCNVector3(x: ballPosition.x + x_, y: cameraPosition.y, z: ballPosition.z + z_)
            self.selfieStickNode.eulerAngles = SCNVector3(-30 * Float.pi/180, self.theta * Float.pi/180, 0)
        }
        /* --------------------------------------------------------- */
        /* Apply force to object - Moving character                  */
        /* --------------------------------------------------------- */
        let velocitydamping = Float(0.0005)
        NotificationCenter.default.addObserver(forName: joystickNotificationName, object: nil, queue: OperationQueue.main) { (notification) in
            guard let userInfo = notification.userInfo else { return }
            
            let data = userInfo["data"] as! AnalogJoystickData
            
            let x_prime = Float(data.velocity.x * joystickVelocityMultiplier) * cos(self.theta * Float.pi/180) - Float(data.velocity.y * joystickVelocityMultiplier) * sin(self.theta * Float.pi/180)
            let z_prime = Float(data.velocity.x * joystickVelocityMultiplier) * sin(self.theta * Float.pi/180) + Float(data.velocity.y * joystickVelocityMultiplier) * cos(self.theta * Float.pi/180)
            
            self.motionForce = SCNVector3(x: x_prime, y:0, z: -z_prime)
            self.ballNode.physicsBody?.velocity += SCNVector3(x: self.motionForce.x * velocitydamping, y: 0, z: self.motionForce.z * velocitydamping)
        }
        
        ballNode.physicsBody?.velocity += SCNVector3(x: motionForce.x * velocitydamping, y:0, z: -motionForce.z * velocitydamping)
        
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
