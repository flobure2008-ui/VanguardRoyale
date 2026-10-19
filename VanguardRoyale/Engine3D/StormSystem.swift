import SceneKit
import UIKit

public class StormSystem {
    public private(set) var stormNode: SCNNode!
    public private(set) var currentRadius: Float = 240.0
    public private(set) var targetRadius: Float = 140.0
    public private(set) var currentCenter: SCNVector3 = SCNVector3(0, 0, 0)
    public private(set) var targetCenter: SCNVector3 = SCNVector3(0, 0, 0)
    
    private var isShrinking: Bool = false
    private var damageTimer: TimeInterval = 0
    
    public init(in scene: SCNScene) {
        setupStormCylinder(in: scene)
        scheduleNextZone()
    }
    
    private func setupStormCylinder(in scene: SCNScene) {
        let cylinder = SCNCylinder(radius: CGFloat(currentRadius), height: 120.0)
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor(red: 0.3, green: 0.1, blue: 0.9, alpha: 0.25)
        mat.emission.contents = UIColor(red: 0.4, green: 0.2, blue: 1.0, alpha: 0.3)
        mat.isDoubleSided = true
        mat.blendMode = .add
        cylinder.materials = [mat]
        
        stormNode = SCNNode(geometry: cylinder)
        stormNode.position = SCNVector3(0, 60.0, 0)
        scene.rootNode.addChildNode(stormNode)
        
        let rotate = CABasicAnimation(keyPath: "rotation")
        rotate.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
        rotate.duration = 40.0
        rotate.repeatCount = .infinity
        stormNode.addAnimation(rotate, forKey: "stormSpin")
    }
    
    public func scheduleNextZone() {
        let maxOffset: Float = 30.0
        targetCenter = SCNVector3(
            currentCenter.x + Float.random(in: -maxOffset...maxOffset),
            0,
            currentCenter.z + Float.random(in: -maxOffset...maxOffset)
        )
        targetRadius = max(20.0, currentRadius * 0.6)
        BattleState.shared.stormTimer = 45
        isShrinking = false
    }
    
    public func update(deltaTime dt: TimeInterval) {
        if !isShrinking {
            if BattleState.shared.stormTimer > 0 {
                // Countdown
            } else {
                isShrinking = true
                BattleState.shared.triggerBanner("⚠️ THE STORM IS SHRINKING!")
            }
        } else {
            // Shrink radius & move center smoothly
            let shrinkRate: Float = 4.5 * Float(dt)
            if currentRadius > targetRadius {
                currentRadius -= shrinkRate
                
                let dx = targetCenter.x - currentCenter.x
                let dz = targetCenter.z - currentCenter.z
                currentCenter.x += dx * 0.05 * Float(dt)
                currentCenter.z += dz * 0.05 * Float(dt)
                
                // Rebuild cylinder geometry
                if let cylinder = stormNode.geometry as? SCNCylinder {
                    cylinder.radius = CGFloat(currentRadius)
                }
                stormNode.position = SCNVector3(currentCenter.x, 60.0, currentCenter.z)
            } else {
                // Completed phase
                BattleState.shared.stormPhase += 1
                scheduleNextZone()
            }
        }
        
        // Damage check outside storm
        damageTimer += dt
        if damageTimer >= 1.0 {
            damageTimer = 0
            checkDamage()
        }
    }
    
    public func isPositionOutsideStorm(_ pos: SCNVector3) -> Bool {
        let dx = pos.x - currentCenter.x
        let dz = pos.z - currentCenter.z
        let dist = sqrt(dx*dx + dz*dz)
        return dist > currentRadius
    }
    
    private func checkDamage() {
        // Player damage check
        let isOutside = BattleState.shared.isInsideStorm
        if isOutside {
            let dmg: Float = Float(BattleState.shared.stormPhase) * 4.0
            BattleState.shared.takeDamage(dmg, from: "The Toxic Storm")
            BattleState.shared.triggerBanner("⚡ TAKING STORM DAMAGE (-4 HP)")
        }
    }
}
