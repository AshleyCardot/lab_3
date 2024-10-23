import SceneKit
import SpriteKit
import CoreMotion

class GameScene: NSObject, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {

    var scene = SCNScene()
    var overlayScene = SKScene(size: CGSize(width: 750, height: 1334))
    let motionManager = CMMotionManager()

    var ballNode: SCNNode!
    var platformNode: SCNNode!
    var collisionLabel = SKLabelNode(text: "Collisions: 0")
    var collisions = 0
    var isBallOnPlatform = false

    override init() {
        super.init()
        setupScene()
    }

    func setupScene() {
        setupCamera()
        
        // Set background to black
        scene.background.contents = UIColor.black
        
        platformNode = createPlatform()
        ballNode = createBall()

        scene.rootNode.addChildNode(platformNode)
        scene.rootNode.addChildNode(ballNode)

        collisionLabel.fontSize = 36
        collisionLabel.fontColor = .white
        collisionLabel.position = CGPoint(x: overlayScene.size.width / 2, y: overlayScene.size.height - 120)
        overlayScene.addChild(collisionLabel)

        setupPhysics()
        startMotionUpdates()
    }

    init(scene: SCNScene, overlayScene: SKScene) {
        self.scene = scene
        self.overlayScene = overlayScene
        super.init()
    }

    // Camera setup
    func setupCamera() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 15, z: 20)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)
    }

    // Ball creation
    func createBall() -> SCNNode {
        let ballGeometry = SCNSphere(radius: 0.5)
        let ball = SCNNode(geometry: ballGeometry)
        ball.position = SCNVector3(0, 2, 0)
        ball.name = "Ball"
        
        ball.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        ball.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.categoryBitMask = 1
        ball.physicsBody?.contactTestBitMask = 2
        return ball
    }

    // Platform creation
    func createPlatform() -> SCNNode {
        let platformGeometry = SCNBox(width: 10, height: 0.5, length: 12, chamferRadius: 0)
        let platform = SCNNode(geometry: platformGeometry)
        platform.position = SCNVector3(0, -0.5, 0)
        platform.name = "Platform"
        
        platform.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        platform.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        platform.physicsBody?.restitution = 1.0
        platform.physicsBody?.categoryBitMask = 2
        platform.physicsBody?.collisionBitMask = 1
        return platform
    }

    func setupPhysics() {
        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
        scene.physicsWorld.contactDelegate = self
    }

    // Start motions
    func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] data, error in
                guard let self = self, let data = data else { return }
                let roll = Float(data.attitude.roll)
                let pitch = Float(data.attitude.pitch)
                let forceMultiplier: Float = 25.0

                let xForce = sin(roll) * forceMultiplier
                let zForce = sin(pitch) * forceMultiplier

                self.ballNode.physicsBody?.applyForce(SCNVector3(xForce, 0, zForce), asImpulse: false)
            }
        }
    }

    // Check if ball has fallen off
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let ballPosition = ballNode.presentation.position
        let fallLimit: Float = -5.0
        
        if ballPosition.y < fallLimit {
            resetBall()
        }
    }

    // Handle collisions
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if let nodeA = contact.nodeA.name, let nodeB = contact.nodeB.name {
            if (nodeA == "Ball" && nodeB == "Platform") || (nodeA == "Platform" && nodeB == "Ball") {
                if !isBallOnPlatform {
                    isBallOnPlatform = true
                    collisions += 1
                    updateCollisionLabel()

                    // Reset isBallOnPlatform after a brief delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.isBallOnPlatform = false
                    }
                }
            }
        }
    }

    // Reset ball position and collisions
    func resetBall() {
        ballNode.position = SCNVector3(0, 2, 0)
        ballNode.physicsBody?.velocity = SCNVector3Zero
        ballNode.physicsBody?.angularVelocity = SCNVector4Zero
        isBallOnPlatform = false
        collisions = 0
        updateCollisionLabel()
    }

    // Update the collision label
    func updateCollisionLabel() {
        collisionLabel.text = "Collisions: \(collisions)"
    }
}
