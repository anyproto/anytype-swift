import Foundation
import AVFoundation


@MainActor
protocol AnytypeAudioPlayerDelegate: AnyObject {
    func playerReadyToPlay(duration: Double)
    func playerReadyToResumeAfterInterruption()
    func playerInterrupted()
    func playerItemDidPlayToEndTime()
    func trackTimeDidChange(timeInSeconds: Double)
    func stopPlaying()
}


@MainActor
protocol AnytypeAudioPlayerProtocol {
    func setAudio(playerItem: AVPlayerItem?, name: String, delegate: some AnytypeAudioPlayerDelegate)
    func play()
    func pause()
    func setTrackTime(value: Double, completion: @escaping @MainActor () -> Void)
}
