import SwiftUI

public struct KillfeedItem: Identifiable {
    public let id = UUID()
    public let killer: String
    public let victim: String
    public let weapon: String
    public let isPlayerInvolved: Bool
}

public class KillfeedManager: ObservableObject {
    public static let shared = KillfeedManager()
    
    @Published public var items: [KillfeedItem] = []
    
    private let botNames = [
        "Ghost_Rider", "ShadowStrike", "Viper_99", "ApexPredator",
        "FalconEye", "Reaper_X", "StormBreaker", "TitanSquad",
        "NightStalker", "Kevlar_King", "IronClad", "Cobra_Sniper",
        "ZeroGravity", "Valkyrie_7", "CyberSoldier", "BulletStorm"
    ]
    
    private let weapons = ["M4A1", "AKM", "AWM", "Pump Shotgun", "Scar-L", "Barrett .50"]
    
    private init() {}
    
    public func addEntry(killer: String, victim: String, weapon: String, isPlayer: Bool = false) {
        let entry = KillfeedItem(killer: killer, victim: victim, weapon: weapon, isPlayerInvolved: isPlayer)
        DispatchQueue.main.async {
            self.items.insert(entry, at: 0)
            if self.items.count > 5 {
                self.items.removeLast()
            }
        }
    }
    
    public func simulateRandomBotBattle() {
        guard BattleState.shared.aliveCount > 2 else { return }
        guard let killer = botNames.randomElement(),
              let victim = botNames.filter({ $0 != killer }).randomElement(),
              let weapon = weapons.randomElement() else { return }
        
        addEntry(killer: killer, victim: victim, weapon: weapon, isPlayer: false)
        BattleState.shared.botEliminated()
    }
}
