
import AVKit
import Combine
import UIKit
import BlocksModels
import AnytypeCore

final class VideoBlockContentView: UIView, BlockContentView {
    private let videoVC = AVPlayerViewController()

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
            "Wrong state \(configuration.file.state) for block file",
            domain: .blockVideo
        )
        
        guard let url = UrlResolver.resolvedUrl(.file(id: configuration.file.metadata.hash)) else { return
        }
        
        videoVC.player = AVPlayer(url: url)
    }
}

extension VideoBlockContentView {
    private enum Constants {
        static let videoViewHeight: CGFloat = 250
        static let videoViewInsets: UIEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 20)
    }
}
