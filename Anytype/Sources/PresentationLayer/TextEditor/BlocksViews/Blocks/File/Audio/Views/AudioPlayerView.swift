//
//  AudioPlayerView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 20.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import AVFoundation


final class AudioPlayerView: UIView {
    private let audioPlayer = AnytypeSharedAudioplayer.sharedInstance
    var playerItem: AVPlayerItem?
    let audioId: String

    private var isPlaying = false
    private var isSeekInProgress = false
    private var isReadyToPlay = false

    // MARK: - Views

    private let playButton = ButtonWithImage()
    private let progressSlider: AudioProgressSlider = {
        let progressSlider = AudioProgressSlider()
        progressSlider.addTarget(self, action: #selector(progressSliderAction), for: .valueChanged)
        return progressSlider
    }()
    private(set) var trackNameLabel = AnytypeLabel(style: .previewTitle2Medium)
    private let durationLabel = AnytypeLabel(style: .caption2Medium)
    private let currentTimeLabel = AnytypeLabel(style: .caption2Medium)
    private let slashView = AnytypeLabel(style: .caption2Medium)

    // MARK: - Lifecycle

    init(audioId: String) {
        self.audioId = audioId

        super.init(frame: .zero)

        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup views

    private func setupViews() {
        playButton.setImage(UIImage(systemName: "play.fill"))
        playButton.imageView.tintColor = .black
        playButton.setMinHitTestArea(.init(width: 35, height: 35))

        playButton.addAction(UIAction(handler: { [weak self] action in
            guard let self = self else { return }

            if self.isPlaying {
                self.pause()
            } else {
                self.play()
            }
        }), for: .touchUpInside)

        slashView.setText(Constants.timingSeparator, style: .caption2Medium)
        currentTimeLabel.setText(Constants.defaultTimingText)
        durationLabel.setText(Constants.defaultTimingText)

        durationLabel.textColor = .textPrimary
        currentTimeLabel.textColor = .textPrimary
        slashView.textColor = .textPrimary

        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.grayscale30.cgColor
    }
    
    private func setupLayout() {
        addSubview(trackNameLabel) {
            $0.top.equal(to: topAnchor, constant: 14)
            $0.leading.equal(to: leadingAnchor, constant: 16)
            $0.trailing.equal(to: trailingAnchor, constant: -16)
        }
        addSubview(playButton) {
            $0.leading.equal(to: trackNameLabel.leadingAnchor)
            $0.top.equal(to: trackNameLabel.bottomAnchor, constant: 9)
            $0.width.equal(to: 16)
            $0.height.equal(to: 18)
            $0.bottom.equal(to: bottomAnchor, constant: -15)
        }
        addSubview(progressSlider) {
            $0.leading.equal(to: playButton.trailingAnchor, constant: 8)
            $0.centerY.equal(to: playButton.centerYAnchor)
            $0.height.equal(to: 16)
        }

        layoutUsing.stack {
            $0.layoutUsing.anchors { [weak self] in
                guard let self = self else { return }
                $0.leading.equal(to: self.progressSlider.trailingAnchor, constant: 5)
                $0.centerY.equal(to: self.playButton.centerYAnchor)
                $0.trailing.equal(to: self.trailingAnchor, constant: -16)
            }
        } builder: {
            return $0.hStack(
                currentTimeLabel,
                $0.hGap(fixed: 2),
                slashView,
                $0.hGap(fixed: 2),
                durationLabel
            )
        }
    }

    // MARK: - Actions

    @objc private func progressSliderAction(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
                switch touchEvent.phase {
                case .began:
                    isSeekInProgress = true
                case .moved:
                    setTimingText(currentTime: slider.value)
                case .ended:
                    audioPlayer.setTrackTime(audioId: audioId, value: Double(slider.value)) { [weak self] in
                        self?.isSeekInProgress = false
                    }
                default:
                    break
                }
            }
    }

    private func play() {
        isPlaying = true
        playButton.setImage(UIImage(systemName: "pause.fill"))

        guard let playerItem = playerItem else {
            return
        }
        let seekTime = Double(progressSlider.value)
        audioPlayer.play(audioId: audioId, playerItem: playerItem, seekTime: seekTime, delegate: self)
    }

    private func pause() {
        isPlaying = false
        playButton.setImage(UIImage(systemName: "play.fill"))
        audioPlayer.pause(audioId: audioId)
    }

    // MARK: - Public methods

    func updateAudioInformation() {
        let duration = Float(playerItem?.asset.duration.seconds ?? 0)
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = duration

        let durationTimeText = formattedTimeText(time: duration)
        durationLabel.setText(durationTimeText)

        if audioPlayer.currentAudioId == audioId {
            progressSlider.value = Float(audioPlayer.currentTime)
            audioPlayer.updateDelegate(audioId: audioId, delegate: self)
        }
//        setTimingText(currentTime: <#T##Float#>)
    }

    // MARK: - Helper methods

    private func setTimingText(currentTime: Float) {
        let timeText = formattedTimeText(time: currentTime)
        currentTimeLabel.setText(timeText)
    }

    private func formattedTimeText(time: Float) -> String {
        let seconds = Int(time) % 60
        let secondsText = seconds != 0 ? String(format: "%02d", Int(time) % 60) : "00"

        let minutes = Int(time) / 60
        let minutesText = minutes != 0 ? String(format: "%02d", Int(time) / 60) : "0"

        let hours = Int(time) / 60 / 60
        let hoursText = hours != 0 ? String(format: "%02d:", Int(time) / 60 / 60) : ""

        return "\(hoursText)\(minutesText):\(secondsText)"
    }
}

extension AudioPlayerView: AnytypeAudioPlayerDelegate {

    func stopPlaying() {
        isReadyToPlay = false
        isPlaying = false
        playButton.setImage(UIImage(systemName: "play.fill"))
    }

    func playerReadyToResumeAfterInterruption() {
        play()
    }

    func playerInterrupted() {
        isPlaying = false
        playButton.setImage(UIImage(systemName: "pause.fill"))
    }

    func trackTimeDidChange(timeInSeconds: Double) {
        if !self.isSeekInProgress, isReadyToPlay {
            self.progressSlider.value = Float(timeInSeconds)
            self.setTimingText(currentTime: Float(timeInSeconds))
        }
    }

    func playerItemDidPlayToEndTime() {
        progressSlider.value = 0
        playButton.setImage(UIImage(systemName: "play.fill"))
    }

    func playerReadyToPlay(duration: Double) {
        let currentTimeText = formattedTimeText(time: Float(duration))
        let durationTimeText = formattedTimeText(time: Float(duration))

        self.currentTimeLabel.setText(currentTimeText)
        self.durationLabel.setText(durationTimeText)

        isReadyToPlay = true
    }
}

private extension AudioPlayerView {
    enum Constants {
        static let defaultTimingText = "0:00"
        static let timingSeparator = "/"
    }
}
