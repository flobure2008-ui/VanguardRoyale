import SwiftUI

public struct HUD3DView: View {
    @ObservedObject var state = BattleState.shared
    @ObservedObject var killfeed = KillfeedManager.shared
    
    var onMove: (Float, Float) -> Void
    var onLook: (Float, Float) -> Void
    var onShoot: () -> Void
    var onJump: () -> Void
    var onReload: () -> Void
    var onBuildWall: () -> Void
    var onToggleADS: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    
    public var body: some View {
        ZStack {
            // 1. Central Crosshairs & Hitmarker
            CrosshairView(isHit: state.showHitmarker, isHeadshot: state.isHeadshot)
            
            // 2. Top Bar: Compass, Alive & Kills, Storm Timer
            VStack(spacing: 8) {
                HStack(alignment: .top) {
                    // Killfeed (Top Left)
                    VStack(alignment: .leading, spacing: 3) {
                        ForEach(killfeed.items) { item in
                            HStack(spacing: 4) {
                                Text(item.killer)
                                    .foregroundColor(item.isPlayerInvolved ? .yellow : .white)
                                    .fontWeight(.bold)
                                Image(systemName: "cross.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.red)
                                Text(item.victim)
                                    .foregroundColor(.gray)
                                Text("[\(item.weapon)]")
                                    .foregroundColor(.cyan)
                                    .font(.system(size: 9))
                            }
                            .font(.system(size: 11, design: .monospaced))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(4)
                        }
                    }
                    .frame(width: 220, alignment: .leading)
                    
                    Spacer()
                    
                    // Compass (Center Top)
                    CompassBar(heading: state.compassHeading)
                        .frame(width: 200, height: 26)
                    
                    Spacer()
                    
                    // Alive Counter & Kills (Top Right)
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.yellow)
                            Text("\(state.aliveCount) ALIVE")
                                .font(.system(size: 13, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "scope")
                                .foregroundColor(.red)
                            Text("\(state.kills) KILLS")
                                .font(.system(size: 13, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                // Storm Warning Banner
                if state.isInsideStorm {
                    Text("⚠️ YOU ARE IN THE STORM! GET TO THE SAFE ZONE!")
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.85))
                        .cornerRadius(6)
                }
                
                // Generic Banner Notification
                if state.showBanner {
                    Text(state.bannerMessage)
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
            }
            
            // 3. Bottom Controls Row: Virtual Joystick (Left) & Weapon/Action Buttons (Right)
            VStack {
                Spacer()
                
                HStack(alignment: .bottom) {
                    // Left Virtual Joystick
                    VirtualJoystick(onDrag: onMove)
                        .frame(width: 140, height: 140)
                        .padding(.leading, 24)
                        .padding(.bottom, 20)
                    
                    Spacer()
                    
                    // Center Health & Shield Bars
                    VStack(alignment: .center, spacing: 4) {
                        // Shield Bar
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 180, height: 8)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.cyan)
                                .frame(width: 180 * CGFloat(state.shield / state.maxShield), height: 8)
                        }
                        
                        // Health Bar
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 180, height: 12)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(state.health < 30 ? Color.red : Color.green)
                                .frame(width: 180 * CGFloat(state.health / state.maxHealth), height: 12)
                        }
                        
                        Text("HP \(Int(state.health)) / 100")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 16)
                    
                    Spacer()
                    
                    // Right Action Area (Look surface, Fire, Jump, Reload, Build)
                    VStack(spacing: 12) {
                        // Secondary Tactical Row (Build Wall, Medkit, Shield)
                        HStack(spacing: 12) {
                            Button(action: onBuildWall) {
                                VStack(spacing: 2) {
                                    Image(systemName: "shield.lefthalf.filled")
                                    Text("BUILD (30)")
                                        .font(.system(size: 8, weight: .bold))
                                }
                                .frame(width: 54, height: 44)
                                .background(Color.brown.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            
                            Button(action: { state.useMedkit() }) {
                                VStack(spacing: 2) {
                                    Image(systemName: "cross.case.fill")
                                    Text("MED (\(state.medkits))")
                                        .font(.system(size: 8, weight: .bold))
                                }
                                .frame(width: 50, height: 44)
                                .background(Color.red.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            
                            Button(action: { state.useShieldPotion() }) {
                                VStack(spacing: 2) {
                                    Image(systemName: "drop.fill")
                                    Text("SHIELD (\(state.shieldPotions))")
                                        .font(.system(size: 8, weight: .bold))
                                }
                                .frame(width: 50, height: 44)
                                .background(Color.cyan.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        
                        // Primary Actions Row (ADS, Reload, Jump, FIRE)
                        HStack(spacing: 14) {
                            Button(action: onToggleADS) {
                                Text("ADS")
                                    .font(.system(size: 12, weight: .black))
                                    .frame(width: 46, height: 46)
                                    .background(state.isADS ? Color.yellow : Color.black.opacity(0.6))
                                    .foregroundColor(state.isADS ? .black : .white)
                                    .clipShape(Circle())
                            }
                            
                            Button(action: onReload) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 14, weight: .bold))
                                    .frame(width: 46, height: 46)
                                    .background(Color.black.opacity(0.6))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                            
                            Button(action: onJump) {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 18, weight: .heavy))
                                    .frame(width: 50, height: 50)
                                    .background(Color.black.opacity(0.6))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                            
                            // Massive Fire Button
                            Button(action: onShoot) {
                                Image(systemName: "scope")
                                    .font(.system(size: 32, weight: .black))
                                    .frame(width: 76, height: 76)
                                    .background(LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .shadow(color: .red.opacity(0.7), radius: 8)
                            }
                        }
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 20)
                }
            }
            
            // 4. Right Pan Area for Aiming (invisible touch layer)
            HStack {
                Spacer()
                Color.clear
                    .frame(width: 280)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                onLook(Float(value.translation.width - dragOffset.width),
                                       Float(value.translation.height - dragOffset.height))
                                dragOffset = value.translation
                            }
                            .onEnded { _ in
                                dragOffset = .zero
                            }
                    )
            }
        }
    }
}

// Subcomponents
private struct CrosshairView: View {
    let isHit: Bool
    let isHeadshot: Bool
    
    var body: some View {
        ZStack {
            // Standard Crosshair
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: 3, height: 3)
            
            // 4 Tick lines
            Rectangle().fill(Color.white).frame(width: 1.5, height: 10).offset(y: -12)
            Rectangle().fill(Color.white).frame(width: 1.5, height: 10).offset(y: 12)
            Rectangle().fill(Color.white).frame(width: 10, height: 1.5).offset(x: -12)
            Rectangle().fill(Color.white).frame(width: 10, height: 1.5).offset(x: 12)
            
            // Hitmarker X
            if isHit {
                ZStack {
                    Rectangle().fill(isHeadshot ? Color.red : Color.white).frame(width: 18, height: 2.5).rotationEffect(.degrees(45))
                    Rectangle().fill(isHeadshot ? Color.red : Color.white).frame(width: 18, height: 2.5).rotationEffect(.degrees(-45))
                }
                .scaleEffect(1.2)
                .transition(.scale)
            }
        }
    }
}

private struct CompassBar: View {
    let heading: Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.black.opacity(0.6))
            
            Text("\(Int(heading))°")
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(.yellow)
        }
    }
}

private struct VirtualJoystick: View {
    var onDrag: (Float, Float) -> Void
    @State private var knobOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.45))
                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1.5))
            
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: 48, height: 48)
                .offset(knobOffset)
        }
        .gesture(
            DragGesture()
                .onChanged { val in
                    let maxRadius: CGFloat = 45.0
                    let dx = val.translation.width
                    let dy = val.translation.height
                    let dist = sqrt(dx*dx + dy*dy)
                    let clampedDist = min(dist, maxRadius)
                    let angle = atan2(dy, dx)
                    
                    knobOffset = CGSize(width: cos(angle) * clampedDist, height: sin(angle) * clampedDist)
                    onDrag(Float(-knobOffset.height / maxRadius), Float(knobOffset.width / maxRadius))
                }
                .onEnded { _ in
                    knobOffset = .zero
                    onDrag(0, 0)
                }
        )
    }
}
