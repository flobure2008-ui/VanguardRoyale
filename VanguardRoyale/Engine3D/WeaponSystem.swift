import SceneKit
import UIKit

public struct WeaponData {
    public let name: String
    public let damage: Float
    public let fireRate: TimeInterval
    public let magSize: Int
    public let reloadTime: TimeInterval
    public let rarity: String
    public let range: Float
    public let isAutomatic: Bool
    public let zoomFOV: CGFloat
}

public class WeaponSystem {
    public static let shared = WeaponSystem()
    
    public let weapons: [WeaponData] = [
        WeaponData(name: "M4A1 ASSAULT", damage: 32.0, fireRate: 0.11, magSize: 30, reloadTime: 1.8, rarity: "RARE", range: 140.0, isAutomatic: true, zoomFOV: 42.0),
        WeaponData(name: "AKM HEAVY", damage: 40.0, fireRate: 0.14, magSize: 30, reloadTime: 2.1, rarity: "EPIC", range: 130.0, isAutomatic: true, zoomFOV: 44.0),
        WeaponData(name: "AWM SNIPER", damage: 125.0, fireRate: 1.25, magSize: 5, reloadTime: 2.8, rarity: "LEGENDARY", range: 280.0, isAutomatic: false, zoomFOV: 22.0),
        WeaponData(name: "PUMP SHOTGUN", damage: 90.0, fireRate: 0.85, magSize: 8, reloadTime: 2.4, rarity: "UNCOMMON", range: 35.0, isAutomatic: false, zoomFOV: 55.0)
    ]
    
    private var lastFireTime: TimeInterval = 0
    
    private init() {}
    
    public var currentWeapon: WeaponData {
        return weapons[BattleState.shared.currentWeaponIndex % weapons.count]
    }
    
    public func canFire() -> Bool {
        let now = CACurrentMediaTime()
        guard !BattleState.shared.isReloading else { return false }
        guard BattleState.shared.currentAmmo > 0 else {
            reload()
            return false
        }
        guard now - lastFireTime >= currentWeapon.fireRate else { return false }
        return true
    }
    
    public func fire() {
        guard canFire() else { return }
        lastFireTime = CACurrentMediaTime()
        BattleState.shared.currentAmmo -= 1
        
        SoundFXEngine.shared.playGunshot(weaponType: currentWeapon.name)
        
        if BattleState.shared.currentAmmo == 0 {
            reload()
        }
    }
    
    public func reload() {
        guard !BattleState.shared.isReloading && BattleState.shared.reserveAmmo > 0 else { return }
        guard BattleState.shared.currentAmmo < currentWeapon.magSize else { return }
        
        BattleState.shared.isReloading = true
        BattleState.shared.triggerBanner("RELOADING...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + currentWeapon.reloadTime) {
            let needed = self.currentWeapon.magSize - BattleState.shared.currentAmmo
            let available = min(needed, BattleState.shared.reserveAmmo)
            BattleState.shared.currentAmmo += available
            BattleState.shared.reserveAmmo -= available
            BattleState.shared.isReloading = false
        }
    }
    
    public func switchWeapon(index: Int) {
        let idx = index % weapons.count
        BattleState.shared.currentWeaponIndex = idx
        let w = weapons[idx]
        BattleState.shared.weaponName = w.name
        BattleState.shared.weaponRarity = w.rarity
        BattleState.shared.currentAmmo = w.magSize
        BattleState.shared.maxMagAmmo = w.magSize
        BattleState.shared.isReloading = false
        BattleState.shared.triggerBanner("EQUIPPED \(w.name)")
    }
}
