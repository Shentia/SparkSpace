//
//  GameScene.swift
//  Aproject20
//
//  Created by Ahmadreza Shamimi on 10/9/17.
//  Copyright © 2017 Ahmadreza Shamimi. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameTimer: Timer!
    var fireWorks = [SKNode]()
    
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var score: Int = 0 {
        didSet {
            //Code Score Here
        }
    }

    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    func createFirework(xMovment: CGFloat, x:Int, y:Int){
        //1
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        //2
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.name = "firework"
        node.addChild(firework)
        //3
        switch GKRandomSource.sharedRandom().nextInt(upperBound: 3) {
        case 0:
            firework.color = .cyan
            firework.colorBlendFactor = 1
        case 1:
            firework.color = .green
            firework.colorBlendFactor = 1
        case 2:
            firework.color = .red
            firework.colorBlendFactor = 1
        default:
            break
        }
        
        //4
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: xMovment, y: 1000))
        
        //5
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        //6
        let emitter = SKEmitterNode(fileNamed: "fuse")!
        emitter.position = CGPoint(x: 0, y: -22)
        node.addChild(emitter)
        
        //7
        fireWorks.append(node)
        addChild(node)
    }
    
    
    @objc func launchFireworks(){
        let movementAmount: CGFloat = 1800
        
        switch GKRandomSource.sharedRandom().nextInt(upperBound: 4) {
        case 0:
            //firefive, straight up
            
            createFirework(xMovment: 0, x: 512, y: bottomEdge)
            createFirework(xMovment: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovment: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovment: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovment: 0, x: 512 + 200, y: bottomEdge)
            
        case 1:
            //fire five , in a fan
            
            createFirework(xMovment: 0, x: 512, y: bottomEdge)
            createFirework(xMovment: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovment: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovment: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovment: 200, x: 512 + 200, y: bottomEdge)
            
        case 2:
            //fire five, from the left to the right
            createFirework(xMovment: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovment: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovment: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovment: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovment: movementAmount, x: leftEdge, y: bottomEdge)
            
        case 3:
            //fire five, from the right to the left
            createFirework(xMovment: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovment: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovment: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovment: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovment: -movementAmount, x: rightEdge, y: bottomEdge)
        default:
            break
        }
        
    }
    
    
    func checkTouches(_ touches: Set<UITouch>) {
        //use  guard every checktouches
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if node is SKSpriteNode {
                let sprite = node as! SKSpriteNode
                
                //got a name to node
                if sprite.name == "firework" {
                    
                    for parent in fireWorks {
                        let firework = parent.children[0] as! SKSpriteNode
                        
                        if firework.name == "selected" && firework.color != sprite.color {
                            firework.name
                             = "firework"
                            firework.colorBlendFactor = 1
                        }
                    }
                    sprite.name = "selected"
                    sprite.colorBlendFactor = 0
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireWorks.enumerated().reversed() {
            
            if firework.position.y > 900 {
                //this a position high above so that rockets can explode off screen
                
                fireWorks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }

   
        func explore(firework: SKNode) {
            let emitter = SKEmitterNode(fileNamed: "explode")!
            emitter.position = firework.position
            addChild(emitter)
            firework.removeFromParent()
        }
        
        func exploreFireWorks() {
            var numExploded = 0
            
            for(index, fireworkContainer) in
                fireWorks.enumerated().reversed() {
                    let firework = fireworkContainer.children[0] as! SKSpriteNode
                    
                    if firework.name == "selected" {
                        //destroy this firework
                        explore(firework: fireworkContainer)
                        fireWorks.remove(at: index)
                        numExploded += 1
           }
        }
            switch numExploded {
            case 0:
                //nothing - rubbish!
                break
            case 1:
                score += 200
            case 2:
                score += 500
            case 3:
                score += 1500
            case 4:
                score += 2500
            default:
                score += 4000
        }
    }
}



    

