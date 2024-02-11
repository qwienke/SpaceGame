//
//  GameScene.swift
//  SpaceGameSKPractice
//
//  Created by Quinn Wienke on 2/11/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var gameTimer: Timer!
    var possibleAliens = ["alien1", "alien2", "alien3"]
    
    let alienCatagory: UInt32 = 0x1 << 1
    let photonTorpedoCatagory: UInt32 = 0x1 << 0
    
    override func didMove(to view: SKView) {
        
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: 0, y: 1472)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        

        player = SKSpriteNode(imageNamed: "shuttle")
//        player.position = CGPoint(add player location)
        
        self.addChild(player)
        
        
        self.physicsWorld.gravity = CGVector(dx:0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        /// Not Working? or just not showing
        scoreLabel = SKLabelNode(text: "Score: 0")
        //scoreLabel.position = CGPoint(x: 100, y: 100)
        scoreLabel.fontName = "ComicSans"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = .white
        score = 0
        
        
        gameTimer = Timer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        RunLoop.main.add(gameTimer, forMode: .common)
        }
        
    @objc func addAlien() {
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        
        let 👽 = SKSpriteNode(imageNamed: possibleAliens[0])
        
        let randomAlienPosition = GKRandomDistribution(lowestValue: 0, highestValue: 414)
        let position = CGFloat(randomAlienPosition.nextInt())
        
        👽.position = CGPoint(x: position, y: self.frame.size.height + 👽.size.height)
        
        👽.physicsBody = SKPhysicsBody(rectangleOf: 👽.size)
        👽.physicsBody?.isDynamic = true
        
        👽.physicsBody?.categoryBitMask = alienCatagory
        👽.physicsBody?.contactTestBitMask = photonTorpedoCatagory
        👽.physicsBody?.collisionBitMask = 0
        
        self.addChild(👽)
        
        let animationDuration: TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -👽.size.height), duration: TimeInterval(animationDuration)))
        actionArray.append(SKAction.removeFromParent())
        
        👽.run(SKAction.sequence(actionArray))
        print("alien spawned")
    }
        
    override func update(_ currentTime: TimeInterval) {
            // Called before each frame is rendered
        }
    }

