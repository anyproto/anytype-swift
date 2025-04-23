import AVKit
import MediaPlayer
import AnytypeCore

@MainActor
final class AnytypeAudioPlayer: AnytypeAudioPlayerProtocol {
    @objc let audioPlayer: AVPlayer
    weak var delegate: (any AnytypeAudioPlayerDelegate)?
    private let timeObserverToken = AtomicStorage<Any?>(nil)
    private var isInterrupted: Bool = false
    private var currentTrackName: String = ""
    private let stateObservation = PlayerItemStateObservation()
    
    var isPlaying: Bool {
        return audioPlayer.rate != 0 && audioPlayer.error == nil
    }

    func duration() async -> Double? {
        return try? await audioPlayer.currentItem?.asset.load(.duration).seconds
    }

    var currentTime: Double {
        return audioPlayer.currentTime().seconds
    }

    // MARK: - Lifecycle

    init() {
        self.audioPlayer = AVPlayer()

        self.setupObservers()
        self.setupMPCommandCenter()
    }

    deinit {
        // If a time observer exists, remove it
        if let token = timeObserverToken.value {
            self.audioPlayer.removeTimeObserver(token)
            timeObserverToken.value = nil
        }
    }

    private func setupMPCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.isEnabled = true

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            self?.delegate?.playerReadyToResumeAfterInterruption()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            self?.delegate?.stopPlaying()
            return .success
        }
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }

            self?.setTrackTime(value: positionEvent.positionTime, completion: {})
            return .success
        }
    }

    private func updatePlayingInfo() {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = currentTrackName
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - Public methos

    func setAudio(playerItem: AVPlayerItem?, name: String, delegate: some AnytypeAudioPlayerDelegate) {
        // tell current delegate that it stops playing
        self.delegate?.stopPlaying()
        // assing new delegate
        self.delegate = delegate
        stateObservation.observe(item: playerItem)
        audioPlayer.replaceCurrentItem(with: nil)
        audioPlayer.replaceCurrentItem(with: playerItem)
        currentTrackName = name
    }

    func play() {
        audioPlayer.play()
        updatePlayingInfo()
    }

    func pause() {
        audioPlayer.pause()
        updatePlayingInfo()
    }

    func setTrackTime(value: Double, completion: @escaping @MainActor () -> Void) {
        let seekTime = CMTime(seconds: value, preferredTimescale: 10)
        audioPlayer.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            Task { @MainActor in
                completion()
                self?.updatePlayingInfo()
            }
        }
    }
}

// MARK: - Private methods

private extension AnytypeAudioPlayer {

    func setupObservers() {
        // Interruption observer
        NotificationCenter.default.addObserver(self,
                       selector: #selector(handleInterruption),
                       name: AVAudioSession.interruptionNotification,
                       object: nil)

        // End track observer
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidPlayToEndTime),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)

        // Periodic time observer
        let interval = CMTimeMake(value: 1, timescale: 10)
        timeObserverToken.value = audioPlayer.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            MainActor.assumeIsolated {
                guard let self = self else { return }
                self.delegate?.trackTimeDidChange(timeInSeconds: time.seconds)
            }
        }
        
        stateObservation.onReadyToPlay = { [weak self] in
            Task { @MainActor in
                if let duration = self?.audioPlayer.currentItem?.duration.seconds {
                    self?.delegate?.playerReadyToPlay(duration: duration)
                }
            }
        }
    }

    @objc func playerItemDidPlayToEndTime() {
        audioPlayer.seek(to: CMTime.zero)
        delegate?.playerItemDidPlayToEndTime()
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        // Switch over the interruption type.
        switch type {
        case .began:
            pause()
            isInterrupted = true
            self.delegate?.playerInterrupted()
        case .ended:
            // An interruption ended. Resume playback, if appropriate.
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)

            if options.contains(.shouldResume), isInterrupted {
                isInterrupted = false
                self.delegate?.playerReadyToResumeAfterInterruption()
            }
        default: ()
        }
    }
}
