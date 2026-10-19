import SceneKit
import UIKit

public enum LootType: CaseIterable {
    case m4a1
    case akm
    case awmSniper
    case shotgun
    case medkit
    case shieldPotion
    case woodCrate
    
    public var label: String {
        switch self {
        case .m4a1: return "M4A1 ASSAULT"
        case .akm: return "AKM RIFLE"
        case .awmSniper: return "AWM SNIPER"
        case .shotgun: return "PUMP SHOTGUN"
        case .medkit: return "MEDKIT (+75 HP)"
        case .shieldPotion: return "SHIELD POTION (+50)"
        case .woodCrate: return "WOOD MATERIALS (+60)"
        }
    }
    
    public var rarityColor: UIColor {
        switch self {
        case .m4a1: return .systemBlue
        case .akm: return .systemPurple
        case .awmSniper: return .systemYellow // Legendary!
        case .shotgun: return .systemGreen
        case .medkit: return .systemRed
        case .shieldPotion: return .cyan
        case .woodCrate: return .brown
        }
    }
}

public class LootItemNode: SCNNode {
    public let type: LootType
    public private(set) var isPickedUp: Bool = false
    
    public init(type: LootType, position: SCNVector3) {
        self.type = type
        super.init()
        self.position = position
        setupLootVisuals()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLootVisuals() {
        self.name = "Loot"
        
        // 1. Core Box
        let boxGeo = SCNBox(width: 0.8, height: 0.5, length: 0.8, chamferRadius: 0.08)
        let boxMat = SCNMaterial()
        boxMat.diffuse.contents = type.rarityColor
        boxMat.emission.contents = type.rarityColor.withAlphaComponent(0.4)
        boxGeo.materials = [boxMat]
        
        let boxNode = SCNNode(geometry: boxGeo)
        boxNode.position = SCNVector3(0, 0.4, 0)
        addChildNode(boxNode)
        
        // 2. Vertical Rarity Beacon Beam
        let beamGeo = SCNCylinder(radius: 0.08, height: 8.0)
        let beamMat = SCNMaterial()
        beamMat.diffuse.contents = type.rarityColor.withAlphaComponent(0.7)
        beamMat.emission.contents = type.rarityColor
        beamMat.blendMode = .add
        beamGeo.materials = [beamMat]
        
        let beamNode = SCNNode(geometry: beamGeo)
        beamNode.position = SCNVector3(0, 4.0, 0)
        addChildNode(beamNode)
        
        // Idle floating and rotating animation
        let rotate = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 3.0)
        boxNode.runAction(SCNAction.repeatForever(rotate))
    }
    
    public func pickup() {
        guard !isPickedUp else { return }
        isPickedUp = true
        
        switch type {
        case .m4a1:
            WeaponSystem.shared.switchWeapon(index: 0)
        case .akm:
            WeaponSystem.shared.switchWeapon(index: 1)
        case .awmSniper:
            WeaponSystem.shared.switchWeapon(index: 2)
        case .shotgun:
            WeaponSystem.shared.switchWeapon(index: 3)
        case .medkit:
            BattleState.shared.medkits += 1
            BattleState.shared.triggerBanner("+1 MEDKIT ACQUIRED")
        case .shieldPotion:
            BattleState.shared.shieldPotions += 1
            BattleState.shared.triggerBanner("+1 SHIELD POTION ACQUIRED")
        case .woodCrate:
            BattleState.shared.woodMaterials += 60
            BattleState.shared.triggerBanner("+60 WOOD MATERIALS")
        }
        
        SoundFXEngine.shared.playShieldPotion()
        self.removeFromParentNode()
    }
}
