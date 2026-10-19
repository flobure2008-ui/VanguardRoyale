import SceneKit
import UIKit

public class PlayerCharacterNode: SCNNode {
    public var cameraNode: SCNNode!
    private var actualCamera: SCNCamera!
    
    private var bodyNode: SCNNode!
    private var headNode: SCNNode!
    private var weaponModelNode: SCNNode!
    private var parachuteNode: SCNNode!
    
    public var isGrounded: Bool = false
    public var verticalVelocity: Float = 0.0
    
    public var currentYaw: Float = 0.0
    public var currentPitch: Float = 0.0
    
    override public init() {
        super.init()
        setupSoldierModel()
        setupThirdPersonCamera()
        setupParachute()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSoldierModel() {
        self.name = "Player"
        
        // 1. Torso
        let torsoGeo = SCNBox(width: 0.9, height: 1.2, length: 0.5, chamferRadius: 0.1)
        let torsoMat = SCNMaterial()
        torsoMat.diffuse.contents = UIColor(red: 0.25, green: 0.32, blue: 0.22, alpha: 1.0) // Military Green Vest
        torsoGeo.materials = [torsoMat]
        bodyNode = SCNNode(geometry: torsoGeo)
        bodyNode.position = SCNVector3(0, 1.2, 0)
        addChildNode(bodyNode)
        
        // 2. Head with Helmet
        let headGeo = SCNSphere(radius: 0.3)
        let headMat = SCNMaterial()
        headMat.diffuse.contents = UIColor(red: 0.2, green: 0.25, blue: 0.18, alpha: 1.0) // Helmet
        headGeo.materials = [headMat]
        headNode = SCNNode(geometry: headGeo)
        headNode.position = SCNVector3(0, 0.8, 0)
        bodyNode.addChildNode(headNode)
        
        // Visor
        let visorGeo = SCNBox(width: 0.35, height: 0.12, length: 0.2, chamferRadius: 0.02)
        let visorMat = SCNMaterial()
        visorMat.diffuse.contents = UIColor(red: 0.0, green: 0.8, blue: 0.9, alpha: 1.0)
        visorGeo.materials = [visorMat]
        let visorNode = SCNNode(geometry: visorGeo)
        visorNode.position = SCNVector3(0, 0.05, 0.22)
        headNode.addChildNode(visorNode)
        
        // 3. Arms & Weapon
        let weaponGeo = SCNBox(width: 0.12, height: 0.2, length: 1.0, chamferRadius: 0.02)
        let weaponMat = SCNMaterial()
        weaponMat.diffuse.contents = UIColor(white: 0.15, alpha: 1.0)
        weaponGeo.materials = [weaponMat]
        weaponModelNode = SCNNode(geometry: weaponGeo)
        weaponModelNode.position = SCNVector3(0.35, 0.1, 0.5)
        bodyNode.addChildNode(weaponModelNode)
        
        // Physics Body
        let capsule = SCNCapsule(capRadius: 0.45, height: 1.8)
        self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: capsule, options: nil))
        self.physicsBody?.categoryBitMask = 4
    }
    
    private func setupThirdPersonCamera() {
        cameraNode = SCNNode()
        actualCamera = SCNCamera()
        actualCamera.zNear = 0.1
        actualCamera.zFar = 600.0
        actualCamera.fieldOfView = 65.0
        cameraNode.camera = actualCamera
        
        // Over-the-shoulder third-person camera offset
        cameraNode.position = SCNVector3(0.7, 2.2, -3.2)
        cameraNode.eulerAngles = SCNVector3(0.1, .pi, 0)
        addChildNode(cameraNode)
    }
    
    private func setupParachute() {
        parachuteNode = SCNNode()
        let canopyGeo = SCNCylinder(radius: 2.4, height: 0.3)
        let canopyMat = SCNMaterial()
        canopyMat.diffuse.contents = UIColor(red: 0.9, green: 0.55, blue: 0.0, alpha: 0.9) // Orange Glider
        canopyGeo.materials = [canopyMat]
        let canopy = SCNNode(geometry: canopyGeo)
        canopy.position = SCNVector3(0, 2.5, 0)
        parachuteNode.addChildNode(canopy)
        
        addChildNode(parachuteNode)
    }
    
    public func update(deltaTime dt: TimeInterval, isSkydiving: Bool) {
        if isSkydiving {
            parachuteNode.isHidden = false
            // Slow descent
            position.y -= 12.0 * Float(dt)
            if position.y <= 1.0 {
                position.y = 1.0
                parachuteNode.isHidden = true
                BattleState.shared.phase = .groundCombat
                BattleState.shared.triggerBanner("TOUCHDOWN! LOOT & SURVIVE!")
            }
        } else {
            parachuteNode.isHidden = true
            // Gravity
            if !isGrounded {
                verticalVelocity -= 22.0 * Float(dt)
                position.y += verticalVelocity * Float(dt)
                if position.y <= 0.0 {
                    position.y = 0.0
                    verticalVelocity = 0.0
                    isGrounded = true
                }
            }
        }
        
        // Smooth ADS Zoom
        let targetFOV: CGFloat = BattleState.shared.isADS ? WeaponSystem.shared.currentWeapon.zoomFOV : 65.0
        actualCamera.fieldOfView += (targetFOV - actualCamera.fieldOfView) * 0.2
    }
    
    public func move(forward: Float, strafe: Float, dt: Float) {
        let speed: Float = 14.0 * dt
        let sinY = sin(currentYaw)
        let cosY = cos(currentYaw)
        
        let dx = (strafe * cosY - forward * sinY) * speed
        let dz = (strafe * sinY + forward * cosY) * speed
        
        position.x += dx
        position.z += dz
        
        // Clamp to island boundary
        position.x = max(-180, min(180, position.x))
        position.z = max(-180, min(180, position.z))
    }
    
    public func rotateLook(deltaX: Float, deltaY: Float) {
        currentYaw -= deltaX * 0.005
        currentPitch = max(-0.8, min(0.8, currentPitch - deltaY * 0.004))
        
        self.eulerAngles.y = currentYaw
        cameraNode.eulerAngles.x = currentPitch
        
        // Update compass in BattleState
        let deg = Double(currentYaw * (180.0 / .pi)).truncatingRemainder(dividingBy: 360.0)
        BattleState.shared.compassHeading = deg < 0 ? deg + 360.0 : deg
    }
    
    public func jump() {
        guard isGrounded else { return }
        isGrounded = false
        verticalVelocity = 8.5
        SoundFXEngine.shared.playBuildWood()
    }
}
