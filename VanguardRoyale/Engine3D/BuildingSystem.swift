import SceneKit
import UIKit

public class BuildingSystem {
    public static func buildWallInFrontOfPlayer(player: PlayerCharacterNode, in scene: SCNScene) {
        guard BattleState.shared.buildTacticalWall() else { return }
        
        let wallGeo = SCNBox(width: 4.5, height: 3.2, length: 0.4, chamferRadius: 0.05)
        let wallMat = SCNMaterial()
        wallMat.diffuse.contents = UIColor(red: 0.6, green: 0.42, blue: 0.25, alpha: 1.0) // Reinforced Wood Planks
        wallMat.roughness.contents = 0.8
        wallGeo.materials = [wallMat]
        
        let wallNode = SCNNode(geometry: wallGeo)
        wallNode.name = "TacticalWall"
        
        // Spawn 3.5m in front of player based on player's yaw angle
        let yaw = player.currentYaw
        let forwardDist: Float = 3.5
        let spawnX = player.position.x - sin(yaw) * forwardDist
        let spawnZ = player.position.z + cos(yaw) * forwardDist
        
        wallNode.position = SCNVector3(spawnX, 1.6, spawnZ)
        wallNode.eulerAngles.y = yaw
        
        let shape = SCNPhysicsShape(geometry: wallGeo, options: nil)
        wallNode.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        wallNode.physicsBody?.categoryBitMask = 2 // Obstacle
        
        // Build animation: scale up from ground
        wallNode.scale = SCNVector3(0.2, 0.2, 0.2)
        scene.rootNode.addChildNode(wallNode)
        
        let scaleUp = SCNAction.scale(to: 1.0, duration: 0.15)
        wallNode.runAction(scaleUp)
        
        BattleState.shared.triggerBanner("TACTICAL WALL DEPLOYED!")
    }
}
