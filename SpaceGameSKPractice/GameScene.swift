//
//  GameScene.swift
//  SpaceGameSKPractice
//
//  Created by Quinn Wienke on 2/11/24.
//

import SpriteKit
import GameplayKit
import CoreMotion

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
    var possibleAliens = ["alien1", "alien2"]
    
    let alienCatagory: UInt32 = 0x1 << 1
    let photonTorpedoCatagory: UInt32 = 0x1 << 0
    
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0
    
    var alienLife = 12
    var torpedoDamage = 6
    
    override func didMove(to view: SKView) {
        //Background
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: 0, y: 1472)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        
        //Player
        let playerSize = CGSize(width: 130, height: 130)
        player = SKSpriteNode(imageNamed: "shuttle")
        player.size = playerSize
        player.position = CGPoint(x: 0, y: -550)
        
        
        self.addChild(player)
        
        //Physics
        self.physicsWorld.gravity = CGVector(dx:0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        /// Score Label
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 0, y: 0)
        scoreLabel.fontName = "ComicSans"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = .white
        score = 0
        addChild(scoreLabel)

        
        
        gameTimer = Timer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        RunLoop.main.add(gameTimer, forMode: .common)
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
            
        }
        
        }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireTorpedo()
    }
        
    @objc func addAlien() {
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        
        let 👽 = SKSpriteNode(imageNamed: possibleAliens[0])
        
        let alienSize = CGSize(width: 100, height: 100)  // Set your desired width and height
            👽.size = alienSize
        
        let randomAlienPosition = GKRandomDistribution(lowestValue: 0, highestValue: Int(self.frame.size.width))
        let xposition = CGFloat(randomAlienPosition.nextInt())
        
        👽.position = CGPoint(x: xposition, y: self.frame.size.height + 👽.size.height)

        
        👽.physicsBody = SKPhysicsBody(rectangleOf: 👽.size)
        👽.physicsBody?.isDynamic = true
        
        👽.physicsBody?.categoryBitMask = alienCatagory
        👽.physicsBody?.contactTestBitMask = photonTorpedoCatagory
        👽.physicsBody?.collisionBitMask = 0
        
        self.addChild(👽)
        
        let animationDuration: TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: xposition, y: -👽.size.height), duration: TimeInterval(animationDuration)))
        actionArray.append(SKAction.removeFromParent())
        
        👽.run(SKAction.sequence(actionArray))
    }
        
    func fireTorpedo() {
        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        let torpedoSize = CGSize(width: 50, height: 50)
        let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
        torpedoNode.size = torpedoSize
        torpedoNode.position = player.position
        torpedoNode.position.y += 5
        
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        torpedoNode.physicsBody?.isDynamic = false
        
        torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCatagory
        torpedoNode.physicsBody?.contactTestBitMask = alienCatagory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(torpedoNode)
        
        let animationDuration: TimeInterval = 0.3
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: TimeInterval(animationDuration)))
        actionArray.append(SKAction.removeFromParent())
        
        torpedoNode.run(SKAction.sequence(actionArray))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & photonTorpedoCatagory) != 0 && (secondBody.categoryBitMask & alienCatagory) != 0 {
            torpedoDidCollideWithAlien(torpedoNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
        }
    }
    
    func torpedoDidCollideWithAlien(torpedoNode: SKSpriteNode, alienNode: SKSpriteNode) {
        
      
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alienNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed ("explosion.mp3", waitForCompletion: false))
        
        torpedoNode.removeFromParent ()
        alienLife -= torpedoDamage
        if alienLife == 0 {
            alienNode.removeFromParent()
            
            self.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
            }
            score += 5
        } else { }
    }
    
    override func didSimulatePhysics() {
        player.position.x += xAcceleration * 50
        
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        } else if player.position.x > self.size.width + 20 {
            player.position = CGPoint(x: -20, y: player.position.y)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
            // Called before each frame is rendered
        }
    }

