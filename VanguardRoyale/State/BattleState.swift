import SwiftUI
import Combine

public enum BattlePhase {
    case skydiving
    case groundCombat
    case victory
    case defeated
}

public class BattleState: ObservableObject {
    public static let shared = BattleState()
    
    @Published public var phase: BattlePhase = .skydiving
    @Published public var health: Float = 100.0
    @Published public var maxHealth: Float = 100.0
    @Published public var shield: Float = 50.0
    @Published public var maxShield: Float = 100.0
    
    @Published public var aliveCount: Int = 30
    @Published public var kills: Int = 0
    @Published public var currentRank: Int = 1
    
    // Weapon & Ammo
    @Published public var currentWeaponIndex: Int = 0
    @Published public var currentAmmo: Int = 30
    @Published public var maxMagAmmo: Int = 30
    @Published public var reserveAmmo: Int = 180
    @Published public var weaponName: String = "M4A1 ASSAULT"
    @Published public var weaponRarity: String = "EPIC"
    @Published public var isReloading: Bool = false
    @Published public var isADS: Bool = false
    
    // Inventory
    @Published public var medkits: Int = 2
    @Published public var shieldPotions: Int = 2
    @Published public var woodMaterials: Int = 120 // For building walls
    
    // Storm & Compass
    @Published public var stormPhase: Int = 1
    @Published public var stormTimer: Int = 45
    @Published public var isInsideStorm: Bool = false
    @Published public var compassHeading: Double = 0.0
    
    // UI Events
    @Published public var showHitmarker: Bool = false
    @Published public var isHeadshot: Bool = false
    @Published public var bannerMessage: String = ""
    @Published public var showBanner: Bool = false
    @Published public var killerName: String = "Enemy Sniper"
    
    private init() {}
    
    public func resetBattle() {
        phase = .skydiving
        health = 100.0
        shield = 50.0
        aliveCount = 30
        kills = 0
        currentRank = 1
        currentAmmo = 30
        maxMagAmmo = 30
        reserveAmmo = 180
        weaponName = "M4A1 ASSAULT"
        weaponRarity = "EPIC"
        isReloading = false
        isADS = false
        medkits = 2
        shieldPotions = 2
        woodMaterials = 150
        stormPhase = 1
        stormTimer = 50
        isInsideStorm = false
        showHitmarker = false
        showBanner = false
        bannerMessage = ""
    }
    
    public func registerHit(headshot: Bool, damage: Float) {
        showHitmarker = true
        isHeadshot = headshot
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.showHitmarker = false
        }
    }
    
    public func takeDamage(_ amount: Float, from source: String) {
        guard phase == .groundCombat || phase == .skydiving else { return }
        
        var remaining = amount
        if shield > 0 {
            if shield >= remaining {
                shield -= remaining
                remaining = 0
            } else {
                remaining -= shield
                shield = 0
            }
        }
        
        if remaining > 0 {
            health = max(0, health - remaining)
        }
        
        if health <= 0 {
            killerName = source
            phase = .defeated
            currentRank = aliveCount
            SoundFXEngine.shared.playPlayerDefeat()
        }
    }
    
    public func recordKill(targetName: String, weapon: String) {
        kills += 1
        aliveCount = max(1, aliveCount - 1)
        triggerBanner("ELIMINATED \(targetName.uppercased())")
        
        if aliveCount == 1 {
            triggerVictory()
        }
    }
    
    public func botEliminated() {
        guard aliveCount > 1 else { return }
        aliveCount = max(1, aliveCount - 1)
        if aliveCount == 1 && (phase == .groundCombat || phase == .skydiving) {
            triggerVictory()
        }
    }
    
    private func triggerVictory() {
        phase = .victory
        currentRank = 1
        SoundFXEngine.shared.playVictoryFanfare()
    }
    
    public func triggerBanner(_ text: String) {
        bannerMessage = text
        showBanner = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            if self?.bannerMessage == text {
                self?.showBanner = false
            }
        }
    }
    
    public func useMedkit() {
        guard medkits > 0 && health < maxHealth else { return }
        medkits -= 1
        health = min(maxHealth, health + 75)
        SoundFXEngine.shared.playHeal()
        triggerBanner("+75 HP HEALTH RESTORED")
    }
    
    public func useShieldPotion() {
        guard shieldPotions > 0 && shield < maxShield else { return }
        shieldPotions -= 1
        shield = min(maxShield, shield + 50)
        SoundFXEngine.shared.playShieldPotion()
        triggerBanner("+50 SHIELD RESTORED")
    }
    
    public func buildTacticalWall() -> Bool {
        guard woodMaterials >= 30 else {
            triggerBanner("NOT ENOUGH MATERIALS (30 NEEDED)")
            return false
        }
        woodMaterials -= 30
        SoundFXEngine.shared.playBuildWood()
        return true
    }
}
