import SceneKit
import UIKit

public class BotAINode: SCNNode {
    public let botName: String
    public var health: Float = 100.0
    public private(set) var isDead: Bool = false
    
    private var bodyNode: SCNNode!
    private var weaponNode: SCNNode!
    private var targetPos: SCNVector3 = SCNVector3(0, 0, 0)
    private var shootCooldown: TimeInterval = 0
    
    public init(name: String, position: SCNVector3) {
        self.botName = name
        super.init()
        self.position = position
        setupBotModel()
        pickNewRoamTarget()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBotModel() {
        self.name = "Bot"
        
        // Torso
        let torsoGeo = SCNBox(width: 0.9, height: 1.2, length: 0.5, chamferRadius: 0.1)
        let torsoMat = SCNMaterial()
        torsoMat.diffuse.contents = UIColor(red: 0.45, green: 0.18, blue: 0.18, alpha: 1.0) // Red/Camo enemy
        torsoGeo.materials = [torsoMat]
        bodyNode = SCNNode(geometry: torsoGeo)
        bodyNode.position = SCNVector3(0, 1.2, 0)
        addChildNode(bodyNode)
        
        // Head
        let headGeo = SCNSphere(radius: 0.3)
        let headMat = SCNMaterial()
        headMat.diffuse.contents = UIColor(white: 0.2, alpha: 1.0)
        headGeo.materials = [headMat]
        let headNode = SCNNode(geometry: headGeo)
        headNode.position = SCNVector3(0, 0.8, 0)
        headNode.name = "BotHead" // For headshots!
        bodyNode.addChildNode(headNode)
        
        // Weapon
        let weaponGeo = SCNBox(width: 0.1, height: 0.18, length: 0.9, chamferRadius: 0.02)
        let weaponMat = SCNMaterial()
        weaponMat.diffuse.contents = UIColor.black
        weaponGeo.materials = [weaponMat]
        weaponNode = SCNNode(geometry: weaponGeo)
        weaponNode.position = SCNVector3(0.3, 0.1, 0.4)
        bodyNode.addChildNode(weaponNode)
        
        // Physics
        let capsule = SCNCapsule(capRadius: 0.5, height: 2.0)
        self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: capsule, options: nil))
        self.physicsBody?.categoryBitMask = 8
    }
    
    public func update(deltaTime dt: TimeInterval, playerPos: SCNVector3, safeZoneCenter: SCNVector3) {
        guard !isDead else { return }
        
        // Distance to player
        let dx = playerPos.x - position.x
        let dz = playerPos.z - position.z
        let dist = sqrt(dx*dx + dz*dz)
        
        if dist < 45.0 {
            // Engage player!
            faceTarget(playerPos)
            shootCooldown += dt
            if shootCooldown >= 1.6 {
                shootCooldown = 0
                fireAtPlayer()
            }
        } else {
            // Move towards safe zone or roam
            moveToTarget(dt: Float(dt))
        }
    }
    
    private func faceTarget(_ target: SCNVector3) {
        let dx = target.x - position.x
        let dz = target.z - position.z
        let angle = atan2(dx, dz)
        self.eulerAngles.y = angle
    }
    
    private func moveToTarget(dt: Float) {
        let dx = targetPos.x - position.x
        let dz = targetPos.z - position.z
        let dist = sqrt(dx*dx + dz*dz)
        
        if dist < 4.0 {
            pickNewRoamTarget()
        } else {
            let speed: Float = 6.0 * dt
            position.x += (dx / dist) * speed
            position.z += (dz / dist) * speed
            faceTarget(targetPos)
        }
    }
    
    private func pickNewRoamTarget() {
        targetPos = SCNVector3(
            position.x + Float.random(in: -30...30),
            0,
            position.z + Float.random(in: -30...30)
        )
    }
    
    private func fireAtPlayer() {
        SoundFXEngine.shared.playGunshot(weaponType: "AKM")
        
        // Inaccuracy spread: 35% chance to hit player
        if Float.random(in: 0...1) < 0.35 {
            let dmg = Float.random(in: 12...22)
            BattleState.shared.takeDamage(dmg, from: botName)
            HapticManager.shared.heavyThud()
        }
    }
    
    public func takeHit(damage: Float, isHeadshot: Bool) {
        guard !isDead else { return }
        health -= damage
        SoundFXEngine.shared.playHitmarker(headshot: isHeadshot)
        BattleState.shared.registerHit(headshot: isHeadshot, damage: damage)
        
        if health <= 0 {
            die()
        }
    }
    
    private func die() {
        isDead = true
        self.physicsBody = nil
        
        BattleState.shared.recordKill(targetName: botName, weapon: WeaponSystem.shared.currentWeapon.name)
        KillfeedManager.shared.addEntry(killer: "YOU", victim: botName, weapon: WeaponSystem.shared.currentWeapon.name, isPlayer: true)
        
        // Death animation: fall over & dissolve
        let fall = SCNAction.rotateBy(x: .pi / 2, y: 0, z: 0, duration: 0.3)
        let fade = SCNAction.fadeOut(duration: 1.2)
        let remove = SCNAction.removeFromParentNode()
        self.runAction(SCNAction.sequence([fall, SCNAction.wait(duration: 1.5), fade, remove]))
    }
}
