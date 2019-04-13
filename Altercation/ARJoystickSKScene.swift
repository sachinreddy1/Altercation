//
//  ARJoystickSKScene.swift
//  Altercation
//
//  Created by Sachin Reddy on 4/13/19.
//  Copyright © 2019 Sachin Reddy. All rights reserved.
//

import SpriteKit

class ARJoystickSKScene: SKScene {
    
    enum NodesZPosition: CGFloat {
        case joystick
    }
    
    lazy var analogJoystick: AnalogJoystick = {
        let js = AnalogJoystick(diameter: 100, colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jStick")))
        js.position = CGPoint(x: js.radius + 45, y: js.radius + 45)
        js.zPosition = NodesZPosition.joystick.rawValue
        return js
    }()
    
    lazy var cameraJoystick: AnalogJoystick = {
        let js = AnalogJoystick(diameter: 100, colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jStick")))
        js.position = CGPoint(x: ScreenSize.width - js.radius - 45, y: js.radius + 45)
        js.zPosition = NodesZPosition.joystick.rawValue
        return js
    }()
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .clear
        setupNodes()
        setupJoystick()
    }
    
    func setupNodes() {
        anchorPoint = CGPoint(x: 0.0, y: 0.0)
    }
    
    func setupJoystick() {
        addChild(analogJoystick)
        addChild(cameraJoystick)
        
        analogJoystick.trackingHandler = { [unowned self] data in
            NotificationCenter.default.post(name: joystickNotificationName, object: nil, userInfo: ["data": data])
        }
        
        cameraJoystick.trackingHandler = { [unowned self] data in
            NotificationCenter.default.post(name: camera_joystickNotificationName, object: nil, userInfo: ["cam_data": data])
        }
        
    }
    
}

