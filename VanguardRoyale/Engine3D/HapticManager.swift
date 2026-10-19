import UIKit

public class HapticManager {
    public static let shared = HapticManager()
    
    private let lightGen = UIImpactFeedbackGenerator(style: .light)
    private let mediumGen = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGen = UIImpactFeedbackGenerator(style: .heavy)
    private let notifyGen = UINotificationFeedbackGenerator()
    
    private init() {
        lightGen.prepare()
        mediumGen.prepare()
        heavyGen.prepare()
        notifyGen.prepare()
    }
    
    public func lightTap() {
        lightGen.impactOccurred()
    }
    
    public func mediumTap() {
        mediumGen.impactOccurred()
    }
    
    public func heavyThud() {
        heavyGen.impactOccurred()
    }
    
    public func victoryNotification() {
        notifyGen.notificationOccurred(.success)
    }
    
    public func defeatNotification() {
        notifyGen.notificationOccurred(.error)
    }
}
