//
//  AnytypeAudioPlayer.swift
//  Anytype
//
//  Created by Denis Batvinkin on 19.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import AVKit


final class AnytypeAudioPlayer: NSObject, AnytypeAudioPlayerProtocol {
    @objc let audioPlayer: AVPlayer
    weak var delegate: AnytypeAudioPlayerDelegate?
    // Key-value observing context
    var playerItemContext = 0
    private var timeObserverToken: Any? = nil
    private var isInterrupted: Bool = false

    var isPlaying: Bool {
        return audioPlayer.rate != 0 && audioPlayer.error == nil
    }

    var duration: Double? {
        return audioPlayer.currentItem?.asset.duration.seconds
    }

    var currentTime: Double {
        return audioPlayer.currentTime().seconds
    }

    // MARK: - Lifecycle

    override init() {
        self.audioPlayer = AVPlayer()

        super.init()

        self.setupObservers()
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

    // MARK: - Public methos

    func setAudio(playerItem: AVPlayerItem?, delegate: AnytypeAudioPlayerDelegate) {
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
    }

    func play() {
        try? AVAudioSession.sharedInstance().setActive(true)
        audioPlayer.play()
    }

    func pause() {
        audioPlayer.pause()
    }

    func setTrackTime(value: Double, completion: @escaping () -> Void) {
        let seekTime = CMTime(seconds: value, preferredTimescale: 10)
        audioPlayer.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero) {_ in
            completion()
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
            guard let self = self else { return }

            self.delegate?.trackTimeDidChange(timeInSeconds: time.seconds)
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
