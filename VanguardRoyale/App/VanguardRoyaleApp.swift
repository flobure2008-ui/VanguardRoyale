import SwiftUI

@main
struct VanguardRoyaleApp: App {
    init() {
        _ = SoundFXEngine.shared
    }
    
    var body: some Scene {
        WindowGroup {
            MainBattleView()
                .preferredColorScheme(.dark)
                .statusBar(hidden: true)
        }
    }
}

struct MainBattleView: View {
    @ObservedObject var state = BattleState.shared
    @State private var controller: Game3DViewController?
    
    var body: some View {
        ZStack {
            // 3D SceneKit View
            Game3DContainerView(controller: $controller)
                .edgesIgnoringSafeArea(.all)
            
            // In-Game Tactical HUD
            if state.phase == .skydiving || state.phase == .groundCombat {
                HUD3DView(
                    onMove: { f, s in controller?.handleMove(forward: f, strafe: s) },
                    onLook: { dx, dy in controller?.handleLook(deltaX: dx, deltaY: dy) },
                    onShoot: { controller?.handleShoot() },
                    onJump: { controller?.handleJump() },
                    onReload: { controller?.handleReload() },
                    onBuildWall: { controller?.handleBuildWall() },
                    onToggleADS: { controller?.handleToggleADS() }
                )
            }
            
            // Victory Royale Screen
            if state.phase == .victory {
                VictoryRoyaleView(onPlayAgain: {
                    controller?.restartBattle()
                })
                .transition(.opacity)
            }
            
            // Defeat Screen
            if state.phase == .defeated {
                DefeatView(onPlayAgain: {
                    controller?.restartBattle()
                })
                .transition(.opacity)
            }
        }
    }
}
