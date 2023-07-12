import AVFoundation
import Combine

//!! IMPORTANT !!
/*
 If you're using 3rd party libraries to play sound or generate sound you should
 set sample rate manually here.
 Otherwise you wont be able to hear any sound when you lock screen
 */
//try AVAudioSession.sharedInstance().setPreferredSampleRate(4096)

public protocol AudioSessionServiceProtocol {
    func setCategorypPlayback()
    func setCategorypPlaybackMixWithOthers()
    
    // TODO: remove with FeatureFlags.fixAudioSession
    func setCategorypPlaybackLegacy()
    func setAudioSessionActiveLegacy()
}

public final class AudioSessionService: AudioSessionServiceProtocol {
    
    public init() {}
    
    public func setCategorypPlayback() {
        setCategorypPlayback(with: [])
    }
    
    public func setCategorypPlaybackMixWithOthers() {
        setCategorypPlayback(with: [.mixWithOthers])
    }
    
    public func setCategorypPlaybackLegacy() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            if !AVAudioSession.sharedInstance().isOtherAudioPlaying {
                try AVAudioSession.sharedInstance().setActive(true)
            }
        } catch { }
    }
    
    public func setAudioSessionActiveLegacy() {
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    private func setCategorypPlayback(with options: AVAudioSession.CategoryOptions) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: options)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {}
    }
}
