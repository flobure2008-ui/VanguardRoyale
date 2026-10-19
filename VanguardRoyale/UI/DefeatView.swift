import SwiftUI

public struct DefeatView: View {
    @ObservedObject var state = BattleState.shared
    var onPlayAgain: () -> Void
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.85).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                VStack(spacing: 6) {
                    Text("YOU WERE ELIMINATED")
                        .font(.system(size: 34, weight: .black, design: .monospaced))
                        .foregroundColor(.red)
                        .shadow(color: .red.opacity(0.8), radius: 12)
                    
                    Text("KILLED BY: \(state.killerName)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 30) {
                    VStack(spacing: 4) {
                        Text("\(state.kills)")
                            .font(.system(size: 30, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                        Text("KILLS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 4) {
                        Text("#\(state.currentRank)")
                            .font(.system(size: 30, weight: .black, design: .monospaced))
                            .foregroundColor(.yellow)
                        Text("RANK")
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
                        .frame(width: 220, height: 50)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
