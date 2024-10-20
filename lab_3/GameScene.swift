import SpriteKit
import CoreMotion

class GameScene: SKScene {
    
    // Define the player node
    let player = SKShapeNode(circleOfRadius: 30)
    
    // CoreMotion Manager to track accelerometer data
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0  // Used for applying accelerometer values
    
    override func didMove(to view: SKView) {
        // Set up the scene background color
        self.backgroundColor = .white
        
        // Set up the player (a blue circle)
        player.fillColor = .blue
        player.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        player.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        addChild(player)
        
        // Start receiving accelerometer updates
        motionManager.startAccelerometerUpdates()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Update the player’s position using accelerometer data
        if let data = motionManager.accelerometerData {
            // Apply x-axis acceleration to move the player horizontally
            xAcceleration = CGFloat(data.acceleration.x) * 100  // Scale the movement
            player.position.x += xAcceleration
            
            // Ensure the player doesn’t move off the screen
            if player.position.x < 0 {
                player.position.x = 0
            } else if player.position.x > self.size.width {
                player.position.x = self.size.width
            }
        }
    }
}
