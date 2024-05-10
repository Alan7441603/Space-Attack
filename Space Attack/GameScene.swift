//
//  GameScene.swift
//  Space Attack
//
//  Created by Alan Rivera on 4/12/24.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    var livesLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var spaceship = SKSpriteNode(imageNamed: "Spaceship")
    var playingGame = false
    var playLabel = SKLabelNode()
    var score = 0
    var lives = 3
    var lasers: [CGPoint] = []
    let ships = ["smallShip", "mediumShip", "largeShip"]
    var shipPoints: [String: Int] = [:] // Dictionary to store points for each ship
    
    override func didMove(to view: SKView) {
        //happens once (when the game opens
        createBackground()
        resetGame()
        makeLabels()
    }
    
    func resetGame() {
        //this stuff happens before each game starts
        createEnemyShips()
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
    
    func createEnemyShips() {
        let rowCount = 6 // rows
        let columnCount = Int(size.width / 100) // columns based on screen width
        let columnWidth = size.width / CGFloat(columnCount)
        let rowHeight = size.height / CGFloat(rowCount) / 2.5 // spacing
        let xMin = -size.width / 2 + columnWidth / 2
        let xMax = size.width / 2 - columnWidth / 2
        
        let moveSideToSide = SKAction.sequence([
            SKAction.moveBy(x: size.width / 10, y: 0, duration: 2.0), // duration
            SKAction.moveBy(x: -size.width / 10, y: 0, duration: 2.0) // duration
        ])
        let moveDown = SKAction.moveBy(x: 0, y: -rowHeight, duration: 1.0) // duration
        let moveSequence = SKAction.sequence([moveSideToSide, moveDown])
        let moveAction = SKAction.repeatForever(moveSequence)
        
        for row in 0..<rowCount {
            for column in 0..<columnCount {
                let enemy = SKSpriteNode(imageNamed: ships.randomElement()!)
                enemy.setScale(0.1) // Scale down to 1/10
                let xPos = xMin + CGFloat(column) * columnWidth
                let yPos = CGFloat(row) * rowHeight + rowHeight / 2
                enemy.position = CGPoint(x: xPos, y: yPos)
                enemy.run(moveAction) // Run the side-to-side and downward movement action
                addChild(enemy)
            }
        }
    }
    
    func setShipPoints() {
        // Set points value for each ship
        shipPoints["smallShip"] = 50
        shipPoints["mediumShip"] = 100
        shipPoints["largeShip"] = 200
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if playingGame {
                spaceship.position.x = location.x
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Call the collisions function to handle the collision
        collisions(contact: contact)
    }
}

class SoundManager {
    static let instance = SoundManager()
    var player: AVAudioPlayer?
    func playSound() {
        //Destination of Weight Sound
        guard let url = Bundle.main.url(forResource: "LaserSound", withExtension: ".wav") else {return}
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } 
        catch let error {
            print("Error playing sound.\(error.localizedDescription)")
            
        }
    }
}

