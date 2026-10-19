import SceneKit
import UIKit

public class BattleRoyaleScene: SCNScene, SCNSceneRendererDelegate {
    public var player: PlayerCharacterNode!
    public var stormSystem: StormSystem!
    private var bots: [BotAINode] = []
    private var lootItems: [LootItemNode] = []
    
    private var sunLight: SCNNode!
    private var lastUpdateTime: TimeInterval = 0
    private var ambientBattleTimer: TimeInterval = 0
    private var airdropTimer: TimeInterval = 0
    
    override public init() {
        super.init()
        setupEnvironmentLighting()
        setupIsland()
        setupPlayer()
        setupBots()
        setupLootSpawns()
        setupStorm()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupEnvironmentLighting() {
        // 1. Directional Sun
        let sun = SCNLight()
        sun.type = .directional
        sun.color = UIColor(white: 1.0, alpha: 1.0)
        sun.castsShadow = true
        sun.shadowMode = .deferred
        sun.shadowSampleCount = 4
        
        sunLight = SCNNode()
        sunLight.light = sun
        sunLight.position = SCNVector3(100, 180, 100)
        sunLight.eulerAngles = SCNVector3(-Float.pi / 3, Float.pi / 4, 0)
        rootNode.addChildNode(sunLight)
        
        // 2. Ambient Sky Fill
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.color = UIColor(red: 0.35, green: 0.42, blue: 0.55, alpha: 1.0)
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        rootNode.addChildNode(ambientNode)
    }
    
    private func setupIsland() {
        TerrainBuilder.buildIsland(in: self)
    }
    
    private func setupPlayer() {
        player = PlayerCharacterNode()
        // Start skydiving high above island!
        player.position = SCNVector3(0, 95.0, 0)
        rootNode.addChildNode(player)
        BattleState.shared.resetBattle()
    }
    
    private func setupBots() {
        let botCount = 24
        let botNames = [
            "Ghost_01", "Viper_99", "Apex_X", "Titan_Rogue", "Falcon",
            "Shadow_Wolf", "Kevlar_9", "IronClad", "Cobra_Sniper", "Reaper",
            "Valkyrie", "BulletStorm", "Phantom", "ZeroCool", "Delta_9",
            "Havoc", "Razor", "Spectre", "Overlord", "Blaze", "Stalker",
            "Nemesis", "Raptor", "Striker"
        ]
        
        for i in 0..<botCount {
            let angle = Float(i) * (.pi * 2 / Float(botCount))
            let radius = Float.random(in: 40...140)
            let x = cos(angle) * radius
            let z = sin(angle) * radius
            
            let name = botNames[i % botNames.count]
            let bot = BotAINode(name: name, position: SCNVector3(x, 0, z))
            bots.append(bot)
            rootNode.addChildNode(bot)
        }
    }
    
    private func setupLootSpawns() {
        let lootLocations: [(Float, Float)] = [
            (-60, -60), (-55, -62), (-65, -58), // Town 1
            (80, 70), (85, 75), (75, 68),       // Military Base
            (-90, 80), (-85, 82),               // Docks
            (60, -80), (62, -75),               // Sniper Ridge
            (0, 0), (15, 10), (-20, 25), (35, -30)
        ]
        
        let types: [LootType] = [.m4a1, .akm, .awmSniper, .shotgun, .medkit, .shieldPotion, .woodCrate]
        for (x, z) in lootLocations {
            let t = types.randomElement() ?? .m4a1
            let loot = LootItemNode(type: t, position: SCNVector3(x, 0, z))
            lootItems.append(loot)
            rootNode.addChildNode(loot)
        }
    }
    
    private func setupStorm() {
        stormSystem = StormSystem(in: self)
    }
    
    // MARK: - Firing & Raycasting
    public func performPlayerShoot() {
        guard WeaponSystem.shared.canFire() else { return }
        WeaponSystem.shared.fire()
        
        let weapon = WeaponSystem.shared.currentWeapon
        
        // Raycast from player camera center in direction of look
        let yaw = player.currentYaw
        let pitch = player.currentPitch
        let maxRange: Float = weapon.range
        
        let dirX = -sin(yaw) * cos(pitch)
        let dirY = sin(pitch)
        let dirZ = cos(yaw) * cos(pitch)
        
        let start = SCNVector3(player.position.x, player.position.y + 1.6, player.position.z)
        let end = SCNVector3(
            start.x + dirX * maxRange,
            start.y + dirY * maxRange,
            start.z + dirZ * maxRange
        )
        
        let hitResults = rootNode.hitTestWithSegment(from: start, to: end, options: [
            SCNHitTestOption.categoryBitMask.rawValue: 8 | 2, // Bots or Buildings
            SCNHitTestOption.searchMode.rawValue: SCNHitTestSearchMode.closest.rawValue
        ])
        
        if let firstHit = hitResults.first {
            let hitNode = firstHit.node
            // Check if hit a bot
            var targetBot: BotAINode? = nil
            var isHead = false
            
            var curr: SCNNode? = hitNode
            while curr != nil {
                if let bot = curr as? BotAINode {
                    targetBot = bot
                    break
                }
                if curr?.name == "BotHead" {
                    isHead = true
                }
                curr = curr?.parent
            }
            
            if let bot = targetBot {
                let multiplier: Float = isHead ? 2.2 : 1.0
                let finalDmg = weapon.damage * multiplier
                bot.takeHit(damage: finalDmg, isHeadshot: isHead)
            }
        }
    }
    
    public func spawnTacticalWall() {
        BuildingSystem.buildWallInFrontOfPlayer(player: player, in: self)
    }
    
    // MARK: - Frame Loop
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = time }
        let dt = time - lastUpdateTime
        lastUpdateTime = time
        
        guard BattleState.shared.phase == .skydiving || BattleState.shared.phase == .groundCombat else { return }
        
        // Update Player
        let isSkydiving = BattleState.shared.phase == .skydiving
        player.update(deltaTime: dt, isSkydiving: isSkydiving)
        
        // Update Storm
        stormSystem.update(deltaTime: dt)
        BattleState.shared.isInsideStorm = stormSystem.isPositionOutsideStorm(player.position)
        
        // Update Bots
        for bot in bots {
            bot.update(deltaTime: dt, playerPos: player.position, safeZoneCenter: stormSystem.targetCenter)
        }
        
        // Check Loot Auto-pickup
        for loot in lootItems {
            guard !loot.isPickedUp else { continue }
            let dx = player.position.x - loot.position.x
            let dz = player.position.z - loot.position.z
            let dist = sqrt(dx*dx + dz*dz)
            if dist < 2.5 {
                loot.pickup()
            }
        }
        
        // Ambient Bot-on-Bot eliminations across the island
        ambientBattleTimer += dt
        if ambientBattleTimer >= 9.0 {
            ambientBattleTimer = 0
            KillfeedManager.shared.simulateRandomBotBattle()
        }
        
        // Airdrop timer
        airdropTimer += dt
        if airdropTimer >= 35.0 {
            airdropTimer = 0
            spawnAirdrop()
        }
    }
    
    private func spawnAirdrop() {
        let x = Float.random(in: -70...70)
        let z = Float.random(in: -70...70)
        let airdrop = LootItemNode(type: .awmSniper, position: SCNVector3(x, 0, z))
        lootItems.append(airdrop)
        rootNode.addChildNode(airdrop)
        
        BattleState.shared.triggerBanner("📦 AIRDROP LANDED NEAR [\(Int(x)), \(Int(z))]!")
        SoundFXEngine.shared.playShieldPotion()
    }
}
