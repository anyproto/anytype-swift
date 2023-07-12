import AVKit
import Combine
import UIKit
import Services
import AnytypeCore

final class VideoBlockContentView: UIView, BlockContentView {
    private let videoVC = AVPlayerViewController()
    private var cancellable: AnyCancellable?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func update(with configuration: VideoBlockConfiguration) {
        apply(configuration: configuration)
    }

    private func setup() {
        addSubview(videoVC.view)
        videoVC.view.edgesToSuperview(insets: Constants.videoViewInsets)
        videoVC.view.heightAnchor.constraint(equalToConstant: Constants.videoViewHeight).isActive = true
    }
    
    private func apply(configuration: VideoBlockConfiguration) {
        anytypeAssert(
            configuration.file.state == .done,
            "Wrong state \(configuration.file.state) for block file"
        )
        
        guard let url = configuration.file.metadata.contentUrl else { return }
        videoVC.player = AVPlayer(url: url)
        
        subscribeOnStatusChange(action: configuration.action)
    }
    
    private func subscribeOnStatusChange(action: @escaping (VideoControlStatus?) -> Void) {
        guard FeatureFlags.fixAudioSession else { return }
        cancellable = videoVC.player?.publisher(for: \.timeControlStatus)
            .sink { status in
                switch status {
                case .playing:
                    action(.playing)
                case .paused:
                    action(.paused)
                default:
                    action(nil)
                }
            }
    }
}

extension VideoBlockContentView {
    private enum Constants {
        static let videoViewHeight: CGFloat = 250
        static let videoViewInsets: UIEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 20)
    }
}
