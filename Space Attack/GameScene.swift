//
//  GameScene.swift
//  Space Attack
//
//  Created by Alan Rivera on 4/12/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var livesLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var spaceship = SKSpriteNode(imageNamed: "Spaceship")
    var playingGame = false
    var playLabel = SKLabelNode()
    var score = 0
    var lives = 3
    var lasers: [CGPoint] = []
    
    override func didMove(to view: SKView) {
        //happens once (when the game opens
        createBackground()
        resetGame()
        makeLabels()
    }
    
    func resetGame() {
        //this stuff happens before each game starts
        createSpaceship()
        updateLabels()
    }
    
    func createBackground() {
        let stars = SKTexture(imageNamed: "Stars")
        for i in 0...1 {
            let starsBackground = SKSpriteNode(texture: stars)
            starsBackground.zPosition = -1
            starsBackground.position = CGPoint(x: 0, y: starsBackground.size.height * CGFloat(i))
            addChild(starsBackground)
            let moveDown = SKAction.moveBy(x: 0, y: -starsBackground.size.height, duration: 20)
            let moveReset = SKAction.moveBy(x: 0, y: starsBackground.size.height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            starsBackground.run(moveForever)
        }
    }
    
    func makeLabels() {
        playLabel.fontSize = 24
        playLabel.text = "Tap to start"
        playLabel.fontName = "Arial"
        playLabel.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        playLabel.name = "playLabel"
        addChild(playLabel)
        
        livesLabel.fontSize = 18
        livesLabel.fontColor = .white
        livesLabel.fontName = "Arial"
        livesLabel.position = CGPoint(x: frame.minX + 50, y: frame.minY + 18)
        addChild(livesLabel)
        
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = .white
        scoreLabel.fontName = "Arial"
        scoreLabel.position = CGPoint(x: frame.maxX - 50, y: frame.minY + 18)
        addChild(scoreLabel)
    }
    
    func updateLabels() {
        scoreLabel.text = ("Score: \(score)")
        livesLabel.text = ("Lives: \(lives)")
    }
    
    func createSpaceship() {
        spaceship.removeFromParent()
        spaceship.position = CGPoint(x: frame.midX, y: frame.minY + 125)
        spaceship.physicsBody?.isDynamic = false
        spaceship.setScale(0.07)
        spaceship.name = "Spaceship"
        addChild(spaceship)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if playingGame {
                spaceship.position.x = location.x
                shootLasers(from: spaceship.position)
            }
            else {
                for node in nodes(at: location) {
                    if node.name == "playLabel" {
                        playingGame = true
                        node.alpha = 0
                        score = 0
                        lives = 3
                        updateLabels()
                        
                    }
                }
            }
        }
    }
    func shootLasers(from startPoint: CGPoint) {
        let newLaserPosition = CGPoint(x: startPoint.x, y: startPoint.y - 20)
        lasers.append(newLaserPosition)
        
        let laserNode = SKSpriteNode(color: .red, size: CGSize(width: 2, height: 20))
        laserNode.position = newLaserPosition
        addChild(laserNode)
        
        let moveAction = SKAction.moveBy(x: 0, y: 750, duration: 1.0)
        let removeAction = SKAction.removeFromParent()
        laserNode.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if playingGame {
                spaceship.position.x = location.x
            }
        }
    }
}
