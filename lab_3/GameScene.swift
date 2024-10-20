import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {

    // Game elements
    let player = SKShapeNode(circleOfRadius: 30)
    let obstacle = SKShapeNode(rectOf: CGSize(width: 60, height: 60))

    // Create a separate instance of CMMotionManager
    let motionManager = CMMotionManager()
    var stepGoalReached = false

    override func didMove(to view: SKView) {
        self.backgroundColor = .white
        
        // Set up player
        player.fillColor = .blue
        player.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        player.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = 0x1 << 0
        player.physicsBody?.collisionBitMask = 0x1 << 1
        player.physicsBody?.contactTestBitMask = 0x1 << 1
        addChild(player)
        
        // Set up obstacle
        obstacle.fillColor = .red
        obstacle.position = CGPoint(x: self.size.width / 2, y: self.size.height - 100)
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.frame.size)
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = 0x1 << 1
        obstacle.physicsBody?.collisionBitMask = 0x1 << 0
        obstacle.physicsBody?.contactTestBitMask = 0x1 << 0
        addChild(obstacle)

        // Set contact delegate
        physicsWorld.contactDelegate = self

        // Start accelerometer updates
        startAccelerometerUpdates()
    }

    func startAccelerometerUpdates() {
        // Start accelerometer updates from the CMMotionManager
        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] data, error in
                if let accelerometerData = data {
                    // Move the player based on the tilt of the phone
                    let xAcceleration = CGFloat(accelerometerData.acceleration.x) * 500
                    let yAcceleration = CGFloat(accelerometerData.acceleration.y) * 500
                    self?.player.position.x += xAcceleration
                    self?.player.position.y += yAcceleration

                    // Boundary check to prevent the player from moving off the screen
                    if self?.player.position.x ?? 0 < 0 { self?.player.position.x = 0 }
                    if self?.player.position.x ?? 0 > self?.size.width ?? 0 { self?.player.position.x = self?.size.width ?? 0 }
                    if self?.player.position.y ?? 0 < 0 { self?.player.position.y = 0 }
                    if self?.player.position.y ?? 0 > self?.size.height ?? 0 { self?.player.position.y = self?.size.height ?? 0 }
                }
            }
        }
    }

    // Add collision detection logic here
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == player || contact.bodyB.node == player {
            print("Collision detected with obstacle!")
            player.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        }
    }
}
