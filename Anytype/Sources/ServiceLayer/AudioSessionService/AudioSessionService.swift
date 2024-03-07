import AVFoundation
import Combine

//!! IMPORTANT !!
/*
 If you're using 3rd party libraries to play sound or generate sound you should
 set sample rate manually here.
 Otherwise you wont be able to hear any sound when you lock screen
 */
//try AVAudioSession.sharedInstance().setPreferredSampleRate(4096)

protocol AudioSessionServiceProtocol {
    func setCategorypPlayback()
    func setCategorypPlaybackMixWithOthers()
}

final class AudioSessionService: AudioSessionServiceProtocol {
    
    public func setCategorypPlayback() {
        setCategorypPlayback(with: [])
    }
    
    public func setCategorypPlaybackMixWithOthers() {
        setCategorypPlayback(with: [.mixWithOthers])
    }
    
    private func setCategorypPlayback(with options: AVAudioSession.CategoryOptions) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: options)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {}
    }
}
