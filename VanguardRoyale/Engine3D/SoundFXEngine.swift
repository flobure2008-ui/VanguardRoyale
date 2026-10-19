import Foundation
import AVFoundation

public class SoundFXEngine {
    public static let shared = SoundFXEngine()
    
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let sampleRate: Double = 44100.0
    private var isEngineRunning = false
    
    private init() {
        setupEngine()
    }
    
    private func setupEngine() {
        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            #endif
            
            audioEngine.attach(playerNode)
            let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
            audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)
            audioEngine.mainMixerNode.outputVolume = 0.9
            
            try audioEngine.start()
            isEngineRunning = true
        } catch {
            print("SoundFXEngine init error: \(error)")
        }
    }
    
    private func generateBuffer(duration: Double, wave: (Double) -> Float) -> AVAudioPCMBuffer? {
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else { return nil }
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        
        let channelData = buffer.floatChannelData![0]
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            channelData[frame] = wave(t)
        }
        return buffer
    }
    
    public func playGunshot(weaponType: String) {
        guard isEngineRunning else { return }
        let duration: Double = weaponType.contains("AWM") ? 0.45 : 0.16
        
        if let buffer = generateBuffer(duration: duration, wave: { t in
            let env = Float(pow(1.0 - t / duration, 2.0))
            let noise = Float.random(in: -0.8...0.8)
            let punch = sin(Float(2.0 * .pi * (180.0 - t * 250.0) * t))
            return (noise * 0.7 + punch * 0.3) * env * 0.6
        }) {
            playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            if !playerNode.isPlaying { playerNode.play() }
        }
    }
    
    public func playHitmarker(headshot: Bool) {
        guard isEngineRunning else { return }
        let duration = headshot ? 0.18 : 0.08
        let freq = headshot ? 2400.0 : 800.0
        
        if let buffer = generateBuffer(duration: duration, wave: { t in
            let env = Float(1.0 - t / duration)
            return sin(Float(2.0 * .pi * freq * t)) * env * 0.45
        }) {
            playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            if !playerNode.isPlaying { playerNode.play() }
        }
    }
    
    public func playHeal() {
        guard isEngineRunning else { return }
        let duration = 0.5
        if let buffer = generateBuffer(duration: duration, wave: { t in
            let progress = t / duration
            let freq = 400.0 + progress * 400.0
            return sin(Float(2.0 * .pi * freq * t)) * Float(sin(progress * .pi)) * 0.3
        }) {
            playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            if !playerNode.isPlaying { playerNode.play() }
        }
    }
    
    public func playShieldPotion() {
        guard isEngineRunning else { return }
        let duration = 0.4
        if let buffer = generateBuffer(duration: duration, wave: { t in
            let freq = 880.0 + sin(t * 50.0) * 120.0
            let env = Float(1.0 - t / duration)
            return sin(Float(2.0 * .pi * freq * t)) * env * 0.3
        }) {
            playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            if !playerNode.isPlaying { playerNode.play() }
        }
    }
    
    public func playBuildWood() {
        guard isEngineRunning else { return }
        let duration = 0.15
        if let buffer = generateBuffer(duration: duration, wave: { t in
            let env = Float(1.0 - t / duration)
            let thud = sin(Float(2.0 * .pi * 90.0 * t))
            let click = Float.random(in: -0.4...0.4)
            return (thud * 0.6 + click * 0.4) * env * 0.45
        }) {
            playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            if !playerNode.isPlaying { playerNode.play() }
        }
    }
    
    public func playVictoryFanfare() {
        guard isEngineRunning else { return }
        let duration = 1.2
        let chord = [523.25, 659.25, 783.99, 1046.50]
        if let buffer = generateBuffer(duration: duration, wave: { t in
            let env = Float(min(1.0, t * 8.0) * (1.0 - t / duration * 0.7))
            var sum: Float = 0.0
            for f in chord {
                sum += sin(Float(2.0 * .pi * f * t))
            }
            return (sum / Float(chord.count)) * env * 0.4
        }) {
            playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            if !playerNode.isPlaying { playerNode.play() }
        }
    }
    
    public func playPlayerDefeat() {
        guard isEngineRunning else { return }
        let duration = 0.8
        if let buffer = generateBuffer(duration: duration, wave: { t in
            let env = Float(1.0 - t / duration)
            let f = max(40.0, 160.0 - t * 120.0)
            return sin(Float(2.0 * .pi * f * t)) * env * 0.5
        }) {
            playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            if !playerNode.isPlaying { playerNode.play() }
        }
    }
}
