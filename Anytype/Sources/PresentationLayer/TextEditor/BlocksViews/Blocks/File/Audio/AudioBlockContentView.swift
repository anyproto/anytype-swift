//
//  AudioBlockContentView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 14.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import AVKit
import Combine
import UIKit
import BlocksModels
import AnytypeCore

final class AudioBlockContentView: UIView, UIContentView {
    private var currentConfiguration: AudioBlockContentConfiguration
    var configuration: UIContentConfiguration {
        get {
            self.currentConfiguration
        }
        set {
            guard let configuration = newValue as? AudioBlockContentConfiguration else { return }
            guard self.currentConfiguration != configuration else { return }
            self.currentConfiguration = configuration

            self.audioPlayer?.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
            apply(configuration: configuration)
        }
    }

    @objc private var audioPlayer: AVPlayer?
    private var isPlaying: Bool = false
    private var isSeekInProgress = false
    // Key-value observing context
    private var playerItemContext = 0

    private let playButton = ButtonWithImage()
    private let volumeSlider: UISlider = {
        let volumeSlider = UISlider()
        volumeSlider.minimumValueImage = UIImage(systemName: "speaker.fill")
        let circleImage = UIImage(systemName: "circle.fill")?.scaled(to: .init(width: 12, height: 12))
            .withTintColor(.backgroundPrimary, renderingMode: .alwaysTemplate)
        volumeSlider.minimumTrackTintColor = .backgroundPrimary
        volumeSlider.setThumbImage(circleImage, for: .normal)
        volumeSlider.setThumbImage(circleImage, for: .highlighted)
        volumeSlider.addTarget(self, action: #selector(volumeSliderAction), for: .valueChanged)
        return volumeSlider
    }()
    private let progressSlider: UISlider = {
        let progressSlider = UISlider()
        let circleImage = UIImage(systemName: "circle.fill")?.scaled(to: .init(width: 12, height: 12))
            .withTintColor(.textSecondary, renderingMode: .alwaysOriginal)
        progressSlider.minimumTrackTintColor = .textSecondary
        progressSlider.setThumbImage(circleImage, for: .normal)
        progressSlider.setThumbImage(circleImage, for: .highlighted)
        progressSlider.addTarget(self, action: #selector(progressSliderAction), for: .valueChanged)
        return progressSlider
    }()
    private let trackNameLabel = AnytypeLabel()
    private let durationLabel = AnytypeLabel()
    private let currentTimeLabel = AnytypeLabel()

    init(configuration: AudioBlockContentConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidPlayToEndTime),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)

        setup()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.audioPlayer?.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    }

    private func setup() {
        backgroundColor = .clear
        playButton.setImage(UIImage(systemName: "play.fill"))
        playButton.imageView.tintColor = .textSecondary
        
        playButton.addAction(UIAction(handler: { [weak self] action in
            guard let self = self else { return }
            
            if self.isPlaying {
                self.pause()
            } else {
                self.play()
            }
        }), for: .touchUpInside)


        let backgroundView = UIView()
        backgroundView.backgroundColor = .lightColdGray

        let contentContainer = UIView()
        addSubview(backgroundView) {
            $0.leading.equal(to: leadingAnchor)
            $0.top.equal(to: topAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.bottom.equal(to: bottomAnchor, constant: -2)
        }

        addSubview(contentContainer) {
            $0.leading.equal(to: leadingAnchor, constant: 20)
            $0.top.equal(to: topAnchor, constant: 0)
            $0.trailing.equal(to: trailingAnchor, constant: -20)
            $0.bottom.equal(to: bottomAnchor, constant: -2)
        }

        contentContainer.addSubview(trackNameLabel) {
            $0.top.equal(to: contentContainer.topAnchor, constant: 5)
            $0.leading.equal(to: contentContainer.leadingAnchor)
            $0.trailing.equal(to: contentContainer.trailingAnchor)
        }
        contentContainer.addSubview(playButton) {
            $0.leading.equal(to: contentContainer.leadingAnchor)
            $0.top.equal(to: trackNameLabel.bottomAnchor, constant: 4)
            $0.width.equal(to: 20)
            $0.height.equal(to: 20)
        }
        contentContainer.addSubview(progressSlider) {
            $0.leading.equal(to: playButton.trailingAnchor, constant: 10)
            $0.centerY.equal(to: playButton.centerYAnchor)
            $0.height.equal(to: 12)
            $0.bottom.equal(to: contentContainer.bottomAnchor, constant: -10)
        }
//        contentContainer.addSubview(volumeSlider) {
//            $0.top.equal(to: progressSlider.bottomAnchor, constant: 5)
//            $0.leading.equal(to: playButton.leadingAnchor)
//            $0.width.equal(to: 100)
//            $0.height.equal(to: 20)
//            $0.bottom.equal(to: bottomAnchor)
//        }

        contentContainer.layoutUsing.stack {
            $0.layoutUsing.anchors { [weak self] in
                guard let self = self else { return }
                $0.leading.equal(to: self.progressSlider.trailingAnchor, constant: 5)
                $0.centerY.equal(to: self.playButton.centerYAnchor)
                $0.trailing.equal(to: contentContainer.trailingAnchor)
            }
        } builder: {
            let slashView = AnytypeLabel()
            slashView.setText("/", style: .uxCalloutRegular)
            currentTimeLabel.setText("0:00", style: .uxCalloutRegular)
            durationLabel.setText("0:00", style: .uxCalloutRegular)
            durationLabel.textColor = .textSecondary
            currentTimeLabel.textColor = .textSecondary
            slashView.textColor = .textSecondary

            return $0.hStack(
                currentTimeLabel,
                $0.hGap(fixed: 2),
                slashView,
                $0.hGap(fixed: 2),
                durationLabel
            )
        }
    }

    private func apply(configuration: AudioBlockContentConfiguration) {
        anytypeAssert(configuration.file.state == .done, "Wrong state \(configuration.file.state) for block file")

        guard let url = UrlResolver.resolvedUrl(.file(id: currentConfiguration.file.metadata.hash)) else {
            return
        }
        trackNameLabel.setText(configuration.file.metadata.name, style: .uxBodyRegular)
        trackNameLabel.textColor = .textSecondary

        setupAudioPlayer(url: url)
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
                if let duration = audioPlayer?.currentItem?.duration {
                    let seconds = duration.seconds

                    let currentTimeText = formattedTimeText(time: Float(seconds))
                    let durationTimeText = formattedTimeText(time: Float(seconds))

                    self.currentTimeLabel.setText(currentTimeText, style: .uxCalloutRegular)
                    self.durationLabel.setText(durationTimeText, style: .uxCalloutRegular)

                    progressSlider.maximumValue = Float(seconds)
                }
            }
        }
    }
}

private extension AudioBlockContentView {
    func setupAudioPlayer(url: URL) {
        let audioPlayer = AVPlayer(url: url)

        self.audioPlayer = audioPlayer
        progressSlider.minimumValue = 0

        let interval = CMTimeMake(value: 1, timescale: 10)

        audioPlayer.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            guard let self = self else { return }

            if !self.isSeekInProgress {
                self.progressSlider.value = Float(time.seconds)
                self.setTimingText(currentTime: Float(time.seconds))
            }
        }

        self.audioPlayer?.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: .new, context: &playerItemContext)
    }

    func play() {
        self.isPlaying = true
        playButton.setImage(UIImage(systemName: "pause.fill"))
        self.audioPlayer?.play()
    }

    func pause() {
        self.isPlaying = false
        self.playButton.setImage(UIImage(systemName: "play.fill"))
        self.audioPlayer?.pause()
    }

    func setTimingText(currentTime: Float) {
        let timeText = formattedTimeText(time: currentTime)
        currentTimeLabel.setText(timeText, style: .uxCalloutRegular)
    }

    func formattedTimeText(time: Float) -> String {
        let seconds = Int(time) % 60
        let secondsText = seconds != 0 ? String(format: "%02d", Int(time) % 60) : "00"

        let minutes = Int(time) / 60
        let minutesText = minutes != 0 ? String(format: "%02d", Int(time) / 60) : "0"

        let hours = Int(time) / 60 / 60
        let hoursText = hours != 0 ? String(format: "%02d:", Int(time) / 60 / 60) : ""

        return "\(hoursText)\(minutesText):\(secondsText)"
    }

    @objc func playerItemDidPlayToEndTime() {
        audioPlayer?.seek(to: CMTime.zero)
        playButton.isSelected = false
        progressSlider.value = 0
        playButton.setImage(UIImage(systemName: "play.fill"))
    }

    @objc func volumeSliderAction(slider: UISlider) {
        audioPlayer?.volume = slider.value
    }

    @objc func progressSliderAction(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
                switch touchEvent.phase {
                case .began:
                    pause()
                    isSeekInProgress = true
                case .moved:
                    let seekTime = CMTime(seconds: Double(slider.value), preferredTimescale: 10)
                    audioPlayer?.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
                    setTimingText(currentTime: slider.value)
                case .ended:
                    play()
                    isSeekInProgress = false
                default:
                    break
                }
            }
    }
}
