import UIKit
import SceneKit
import SpriteKit

class GameViewController: UIViewController {
    
    var sceneView: SCNView!
    var gameScene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the SCNView and add it to the view controller
        sceneView = SCNView(frame: self.view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(sceneView)
        
        // Configure the sceneView
        sceneView.allowsCameraControl = false
        sceneView.showsStatistics = false
        sceneView.backgroundColor = UIColor.black
        
        // Create and configure the scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        // Create an overlay SKScene
        let overlayScene = SKScene(size: self.view.bounds.size)
        overlayScene.scaleMode = .resizeFill
        sceneView.overlaySKScene = overlayScene
        
        // Initialize the GameScene
        gameScene = GameScene(scene: scene, overlayScene: overlayScene)
        gameScene.setupScene()
        
        sceneView.delegate = gameScene
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
