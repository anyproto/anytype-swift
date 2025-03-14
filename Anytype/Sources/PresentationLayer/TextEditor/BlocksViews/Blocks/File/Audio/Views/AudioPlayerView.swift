import UIKit
import AVFoundation


@MainActor
protocol AudioPlayerViewDelegate: AnyObject {
    var audioPlayerView: (any AudioPlayerViewInput)? { get set }
    var currentTime: Double { get }
    /// Track duration in seconds
    var isPlaying: Bool { get }
    
    func duration() async -> Double
    func isPlayable() async -> Bool
    func playButtonDidPress(sliderValue: Double)
    func progressSliederChanged(value: Double, completion: @escaping () -> Void)
    func pauseCurrentAudio()
}

@MainActor
protocol AudioPlayerViewInput: AnyObject {
    func trackTimeChanged(_ timeInSeconds: Double)
    func play()
    func pause()
}

final class AudioPlayerView: UIView {
    private var isSeekInProgress = false

    private weak var delegate: (any AudioPlayerViewDelegate)?

    // MARK: - Views

    private let playButton = ButtonWithImage()
    private let progressSlider = AudioProgressSlider()
    private(set) var trackNameLabel = AnytypeLabel(style: .previewTitle2Medium)
    private let durationLabel = AnytypeLabel(style: .caption2Medium)
    private let currentTimeLabel = AnytypeLabel(style: .caption2Medium)
    private let slashView = AnytypeLabel(style: .caption2Medium)

    // MARK: - Lifecycle

    init() {
        super.init(frame: .zero)

        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        guard window.isNil else { return }
        pause()
        delegate?.pauseCurrentAudio()
    }

    // MARK: - Setup views

    private func setupViews() {
        playButton.setImage(UIImage(systemName: "play.fill"))
        playButton.setMinHitTestArea(.init(width: 35, height: 35))
        configurePlayButtonActivity()

        playButton.addAction(UIAction(handler: { [weak self] action in
            guard let self = self else { return }

            self.delegate?.playButtonDidPress(sliderValue: Double(self.progressSlider.value))
        }), for: .touchUpInside)

        progressSlider.addTarget(self, action: #selector(progressSliderAction), for: .valueChanged)

        slashView.setText(Constants.timingSeparator, style: .caption2Medium)
        currentTimeLabel.setText(Constants.defaultTimingText)
        durationLabel.setText(Constants.defaultTimingText)

        durationLabel.textColor = .Text.primary
        currentTimeLabel.textColor = .Text.primary
        slashView.textColor = .Text.primary

        trackNameLabel.textColor = .Text.primary

        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.borderWidth = 0.5
        dynamicBorderColor = UIColor.Shape.primary
    }
    
    private func configurePlayButtonActivity(_ isActive: Bool = true) {
        playButton.imageView.tintColor = isActive ? .Text.primary : .Text.secondary
        playButton.isEnabled = isActive
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
                delegate?.progressSliederChanged(value: Double(slider.value)) { [weak self] in
                    self?.isSeekInProgress = false
                }
            default:
                break
            }
        }
    }

    // MARK: - Public methods

    func updateAudioInformation(delegate: (any AudioPlayerViewDelegate)?) {
        Task {
            await updateAudioInformationAsync(delegate: delegate)
        }
    }
    
    private func updateAudioInformationAsync(delegate: (any AudioPlayerViewDelegate)?) async {
        guard let delegate = delegate else {
            return
        }
        
        let isPlayable = await delegate.isPlayable()
        configurePlayButtonActivity(isPlayable)
        
        let duration = await delegate.duration()
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = Float(duration)
        
        let durationTimeText = formattedTimeText(time: Float(duration))
        durationLabel.setText(durationTimeText)

        progressSlider.value = Float(delegate.currentTime)
        setTimingText(currentTime: Float(delegate.currentTime))

        delegate.isPlaying ? play() : pause()
    }

    func setDelegate(delegate: (any AudioPlayerViewDelegate)?) {
        guard let delegate = delegate else {
            return
        }
        self.delegate?.audioPlayerView = nil
        self.delegate = delegate
        delegate.audioPlayerView = self
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

// MARK: - AudioBlockViewModelOutput

extension AudioPlayerView: AudioPlayerViewInput {
    func play() -> Void {
        playButton.setImage(UIImage(systemName: "pause.fill"))
    }

    func pause() -> Void {
        playButton.setImage(UIImage(systemName: "play.fill"))
    }

    func trackTimeChanged(_ timeInSeconds: Double) {
        if !self.isSeekInProgress {
            self.progressSlider.value = Float(timeInSeconds)
            self.setTimingText(currentTime: Float(timeInSeconds))
        }
    }
}

// MARK: - Constants

private extension AudioPlayerView {
    enum Constants {
        static let defaultTimingText = "0:00"
        static let timingSeparator = "/"
    }
}
