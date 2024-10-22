import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKShapeNode(circleOfRadius: 30)
    let obstacle = SKShapeNode(rectOf: CGSize(width: 60, height: 60))
    let motionManager = CMMotionManager()
    
    var collisionCount = 0  // Counter for number of collisions
    let collisionLabel = SKLabelNode(text: "Collisions: 0")
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .white
        
        // Set up player
        player.fillColor = .blue
        player.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        player.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        player.physicsBody?.restitution = 0.7  // Increase to make the ball bouncy
        player.physicsBody?.friction = 0.1
        player.physicsBody?.categoryBitMask = 0x1 << 0  // Player category
        player.physicsBody?.collisionBitMask = 0x1 << 1  // Collide only with obstacle
        player.physicsBody?.contactTestBitMask = 0x1 << 1  // Detect contact only with obstacle
        addChild(player)
        
        // Set up obstacle
        obstacle.fillColor = .red
        obstacle.position = CGPoint(x: self.size.width / 2, y: self.size.height - 120)
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.frame.size)
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = 0x1 << 1  // Obstacle category
        obstacle.physicsBody?.collisionBitMask = 0x1 << 0  // Collide only with player
        obstacle.physicsBody?.contactTestBitMask = 0x1 << 0  // Detect contact only with player
        addChild(obstacle)
        
        // Set up edge boundaries around the screen
        let screenEdge = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = screenEdge // Make the screen edges act as boundaries only
        
        // Set contact delegate
        physicsWorld.contactDelegate = self
        
        // Set up collision label
        collisionLabel.fontColor = .black
        collisionLabel.fontSize = 36  // Increase font size for better visibility
        collisionLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height - 80)  // Adjust position
        addChild(collisionLabel)
        
        // Start accelerometer updates
        startAccelerometerUpdates()
    }
    
    func startAccelerometerUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] data, error in
                if let accelerometerData = data {
                    // Apply larger force to increase speed
                    let xForce = CGFloat(accelerometerData.acceleration.x) * 1000
                    let yForce = CGFloat(accelerometerData.acceleration.y) * 1000
                    self?.player.physicsBody?.applyForce(CGVector(dx: xForce, dy: yForce))
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.node == player && contact.bodyB.node == obstacle) ||
            (contact.bodyB.node == player && contact.bodyA.node == obstacle) {
            
            print("Collision detected with obstacle!")
            
            // Flash the obstacle on collision
            let flashAction = SKAction.sequence([
                SKAction.colorize(with: .yellow, colorBlendFactor: 1.0, duration: 0.1),
                SKAction.wait(forDuration: 0.1),
                SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.1)
            ])
            obstacle.run(flashAction)
            
            // Increment the collision counter and update the label
            collisionCount += 1
            collisionLabel.text = "Collisions: \(collisionCount)"
        }
    }
}
