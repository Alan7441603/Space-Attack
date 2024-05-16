
//
//  GameScene.swift
//  Space Attack
//
//  Created by Alan Rivera on 4/12/24.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
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
        // happens once(when the game opens)
        setShipPoints()
        createBackground()
        resetGame()
        makeLabels()
        physicsWorld.contactDelegate = self
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
        scoreLabel.position = CGPoint(x: frame.maxX - 80, y: frame.minY + 18)
        addChild(scoreLabel)
    }
    
    func createSpaceship() {
        spaceship.removeFromParent()
        spaceship.position = CGPoint(x: frame.midX, y: frame.minY + 125)
        
        // Initialize the physics body with a rectangle of the size of the spaceship
        spaceship.physicsBody = SKPhysicsBody(rectangleOf: spaceship.size)
        
        // Configure the physics body properties
        spaceship.physicsBody?.isDynamic = true // Allow the ship to move based on forces and collisions
        spaceship.physicsBody?.affectedByGravity = false // Don't let gravity affect the ship
        spaceship.physicsBody?.allowsRotation = false // Prevent the ship from rotating due to collisions
        
        // Set the category bit mask for the player's ship
        spaceship.physicsBody?.categoryBitMask = 1 << 0 // Category for player's ship
        // Set the collision and contact test bit masks
        spaceship.physicsBody?.collisionBitMask = 0 // Specify which categories the ship should collide with
        spaceship.physicsBody?.contactTestBitMask = 1 << 3 // Specify which categories the ship should test for contact with
        
        spaceship.setScale(0.05)
        spaceship.name = "Spaceship"
        addChild(spaceship)
    }
    
    func createEnemyShips() {
        let rowCount = 6
        let columnCount = Int(size.width / 100)
        let columnWidth = size.width / CGFloat(columnCount)
        let rowHeight = size.height / CGFloat(rowCount) / 2.5
        
        for row in 0..<rowCount {
            for column in 0..<columnCount {
                if let shipType = ships.randomElement() {
                    let enemy = SKSpriteNode(imageNamed: shipType)
                    enemy.setScale(0.1)
                    
                    // Calculate the x and y positions for the enemy ship
                    let xPos = CGFloat(column) * columnWidth - size.width / 2 + columnWidth / 2
                    let yPos = size.height / 2 - CGFloat(row) * rowHeight
                    
                    enemy.position = CGPoint(x: xPos, y: yPos)
                    
                    // Assign physics body and set affectedByGravity to false
                    enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
                    enemy.physicsBody?.isDynamic = true
                    enemy.physicsBody?.affectedByGravity = false
                    enemy.physicsBody?.categoryBitMask = 1 << 2 // Category for enemy ships
                    enemy.physicsBody?.contactTestBitMask = 1 << 1 // Contact with lasers
                    enemy.physicsBody?.collisionBitMask = 0 // No collision response needed
                    
                    // Define movement actions for the enemy ship
                    let moveSideToSide = SKAction.sequence([
                        SKAction.moveBy(x: size.width / 10, y: 0, duration: 2.0),
                        SKAction.moveBy(x: -size.width / 10, y: 0, duration: 2.0)
                    ])
                    let moveDown = SKAction.moveBy(x: 0, y: -rowHeight, duration: 1.0)
                    let moveSequence = SKAction.sequence([moveSideToSide, moveDown])
                    let moveAction = SKAction.repeatForever(moveSequence)
                    
                    // Run the actions on the enemy ship
                    enemy.run(moveAction)
                    // Add enemy shooting lasers randomly
                    let shootLaserAction = SKAction.run {
                        self.enemyLaser(enemy)
                    }
                    let randomWait = SKAction.wait(forDuration: Double.random(in: 4.0...8.0))
                    let shootSequence = SKAction.sequence([randomWait, shootLaserAction])
                    let repeatShooting = SKAction.repeatForever(shootSequence)
                    enemy.run(repeatShooting)
                    enemy.name = shipType // Set the name of the enemy to its type for scoring
                    addChild(enemy)
                }
            }
        }
    }
    
    func enemyShipDestroyed(enemy: SKSpriteNode) {
           if let shipType = enemy.name, let points = shipPoints[shipType] {
               score += points
               updateLabels()
           }
       }
    
    func enemyLaser(_ enemy: SKSpriteNode) {
        let laser = SKSpriteNode(color: .blue, size: CGSize(width: 2, height: 20))
        laser.position = enemy.position
        laser.position.y -= enemy.size.height / 2
        
        addChild(laser)
        
        laser.physicsBody = SKPhysicsBody(rectangleOf: laser.size)
        laser.physicsBody?.isDynamic = true
        laser.physicsBody?.affectedByGravity = false
        laser.physicsBody?.categoryBitMask = 1 << 3 // New category for enemy lasers
        laser.physicsBody?.contactTestBitMask = 1 << 0 // Contact with spaceship
        laser.physicsBody?.collisionBitMask = 0
        
        let moveAction = SKAction.moveBy(x: 0, y: -frame.height, duration: 3.0)
        let removeAction = SKAction.removeFromParent()
        
        laser.run(SKAction.sequence([moveAction, removeAction]))
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
        
        laserNode.physicsBody = SKPhysicsBody(rectangleOf: laserNode.size)
        laserNode.physicsBody?.isDynamic = true
        laserNode.physicsBody?.affectedByGravity = false
        laserNode.physicsBody?.categoryBitMask = 1 << 1 // Category for lasers
        laserNode.physicsBody?.contactTestBitMask = 1 << 2 // Contact with enemy ships
        laserNode.physicsBody?.collisionBitMask = 0 // No collision response needed
        
        
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
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        // Check if a laser and an enemy ship have collided
        if (firstBody.categoryBitMask == 1 << 1 && secondBody.categoryBitMask == 1 << 2) ||
            (firstBody.categoryBitMask == 1 << 2 && secondBody.categoryBitMask == 1 << 1) {
            
            // Determine the laser and enemy ship nodes
            let laser = firstBody.categoryBitMask == 1 << 1 ? firstBody.node : secondBody.node
            let enemy = firstBody.categoryBitMask == 1 << 2 ? firstBody.node : secondBody.node
            
            // Remove the laser and enemy ship from the scene
            laser?.removeFromParent()
            enemy?.removeFromParent()
            
            // Update the score based on the type of enemy ship
            if let enemyNode = enemy as? SKSpriteNode {
                enemyShipDestroyed(enemy: enemyNode)
            }
        }
        
        // Check if an enemy laser and the player's ship have collided
        if (firstBody.categoryBitMask == 1 << 3 && secondBody.categoryBitMask == 1 << 0) ||
            (firstBody.categoryBitMask == 1 << 0 && secondBody.categoryBitMask == 1 << 3) {
            
            // Determine the enemy laser and player's ship nodes
            let enemyLaser = firstBody.categoryBitMask == 1 << 3 ? firstBody.node : secondBody.node
            
            // Remove the enemy laser from the scene
            enemyLaser?.removeFromParent()
            
            // Decrease player lives and update labels
            lives -= 1
            updateLabels()
            
            // Check if the player has lost all lives
            if lives <= 0 {
                gameOver()
            }
        }
    }
    
    
    func addScore(for enemyName: String) {
        // Increment score based on the type of ship destroyed
        if let points = shipPoints[enemyName] {
            score += points
            updateLabels()
        }
    }
    
    func gameOver() {
        // Handle game over scenario
        print("Game Over! Player has lost all lives.")
        playingGame = false
        playLabel.alpha = 1
    }
    
    func updateLabels() {
        // Update the score and lives labels
        self.scoreLabel.text = "Score: \(self.score)"
        self.livesLabel.text = "Lives: \(self.lives)"
    }
}
