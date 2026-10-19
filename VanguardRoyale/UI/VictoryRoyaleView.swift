import SwiftUI

public struct VictoryRoyaleView: View {
    @ObservedObject var state = BattleState.shared
    var onPlayAgain: () -> Void
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.85).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                // #1 Victory Royale Banner
                VStack(spacing: 8) {
                    Text("★ #1 ★")
                        .font(.system(size: 34, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                    
                    Text("VICTORY ROYALE")
                        .font(.system(size: 42, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                        .shadow(color: .orange, radius: 16)
                    
                    Text("WINNER WINNER CHICKEN DINNER!")
                        .font(.system(size: 14, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                // Stats Card
                HStack(spacing: 30) {
                    VStack(spacing: 4) {
                        Text("\(state.kills)")
                            .font(.system(size: 32, weight: .black, design: .monospaced))
                            .foregroundColor(.red)
                        Text("TOTAL KILLS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 4) {
                        Text("#1")
                            .font(.system(size: 32, weight: .black, design: .monospaced))
                            .foregroundColor(.yellow)
                        Text("FINAL RANK")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 4) {
                        Text("SURVIVOR")
                            .font(.system(size: 24, weight: .black, design: .monospaced))
                            .foregroundColor(.green)
                        Text("STATUS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(Color(red: 0.12, green: 0.12, blue: 0.16))
                .cornerRadius(12)
                
                Spacer()
                
                Button(action: onPlayAgain) {
                    Text("PLAY AGAIN")
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .frame(width: 240, height: 54)
                        .background(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .shadow(color: .yellow.opacity(0.6), radius: 10)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
