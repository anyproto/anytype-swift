import AVKit
import MediaPlayer
import AnytypeCore

@MainActor
final class AnytypeAudioPlayer: NSObject, AnytypeAudioPlayerProtocol {
    @objc let audioPlayer: AVPlayer
    weak var delegate: (any AnytypeAudioPlayerDelegate)?
    // Key-value observing context
    var playerItemContext = 0
    private var timeObserverToken: Any? = nil
    private var isInterrupted: Bool = false
    private var currentTrackName: String = ""

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

    override init() {
        self.audioPlayer = AVPlayer()

        super.init()

        self.setupObservers()
        self.setupMPCommandCenter()
    }

    deinit {
        self.audioPlayer.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))

        // If a time observer exists, remove it
        if let token = timeObserverToken {
            self.audioPlayer.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {

        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            if status == .readyToPlay {
                if let duration = audioPlayer.currentItem?.duration.seconds {
                    delegate?.playerReadyToPlay(duration: duration)
                }
            }
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
        audioPlayer.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        audioPlayer.replaceCurrentItem(with: nil)
        audioPlayer.replaceCurrentItem(with: playerItem)
        // Item status observer
        audioPlayer.currentItem?.addObserver(self,
                                             forKeyPath: #keyPath(AVPlayerItem.status),
                                             options: .new,
                                             context: &playerItemContext)
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
        timeObserverToken = audioPlayer.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            MainActor.assumeIsolated {
                guard let self = self else { return }
                self.delegate?.trackTimeDidChange(timeInSeconds: time.seconds)
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
