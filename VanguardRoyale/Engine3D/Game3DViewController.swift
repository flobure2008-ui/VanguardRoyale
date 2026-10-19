import UIKit
import SceneKit
import SwiftUI

public class Game3DViewController: UIViewController {
    public var scnView: SCNView!
    public var gameScene: BattleRoyaleScene!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        scnView = SCNView(frame: view.bounds)
        scnView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scnView.backgroundColor = UIColor(red: 0.45, green: 0.65, blue: 0.85, alpha: 1.0) // Sky Blue
        scnView.preferredFramesPerSecond = 120
        scnView.antialiasingMode = .multisampling4X
        
        gameScene = BattleRoyaleScene()
        scnView.scene = gameScene
        scnView.delegate = gameScene
        scnView.pointOfView = gameScene.player.cameraNode
        
        view.addSubview(scnView)
    }
    
    public func handleMove(forward: Float, strafe: Float) {
        gameScene?.player.move(forward: forward, strafe: strafe, dt: 1.0 / 60.0)
    }
    
    public func handleLook(deltaX: Float, deltaY: Float) {
        gameScene?.player.rotateLook(deltaX: deltaX, deltaY: deltaY)
    }
    
    public func handleShoot() {
        gameScene?.performPlayerShoot()
    }
    
    public func handleJump() {
        gameScene?.player.jump()
    }
    
    public func handleReload() {
        WeaponSystem.shared.reload()
    }
    
    public func handleBuildWall() {
        gameScene?.spawnTacticalWall()
    }
    
    public func handleToggleADS() {
        BattleState.shared.isADS.toggle()
    }
    
    public func restartBattle() {
        gameScene = BattleRoyaleScene()
        scnView.scene = gameScene
        scnView.delegate = gameScene
        scnView.pointOfView = gameScene.player.cameraNode
    }
}

public struct Game3DContainerView: UIViewControllerRepresentable {
    @Binding var controller: Game3DViewController?
    
    public func makeUIViewController(context: Context) -> Game3DViewController {
        let vc = Game3DViewController()
        DispatchQueue.main.async {
            self.controller = vc
        }
        return vc
    }
    
    public func updateUIViewController(_ uiViewController: Game3DViewController, context: Context) {}
}
