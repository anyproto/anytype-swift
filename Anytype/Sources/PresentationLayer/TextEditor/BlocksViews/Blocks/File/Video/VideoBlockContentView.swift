
import AVKit
import Combine
import UIKit
import BlocksModels

final class VideoBlockContentView: UIView, UIContentView {
    private var currentConfiguration: VideoBlockConfiguration
    var configuration: UIContentConfiguration {
        get {
            self.currentConfiguration
        }
        set {
            guard let configuration = newValue as? VideoBlockConfiguration else { return }
            guard self.currentConfiguration != configuration else { return }
            self.currentConfiguration = configuration
            
            apply(configuration: configuration)
        }
    }
    
    private let videoVC = AVPlayerViewController()
    
    init(configuration: VideoBlockConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        
        setup()
        apply(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(videoVC.view)
        videoVC.view.edgesToSuperview(insets: Constants.videoViewInsets)
        videoVC.view.heightAnchor.constraint(equalToConstant: Constants.videoViewHeight).isActive = true
    }
    
    private func apply(configuration: VideoBlockConfiguration) {
        assert(configuration.file.state == .done, "Wrong state \(configuration.file.state) for block file")
        
        guard let url = UrlResolver.resolvedUrl(.file(id: currentConfiguration.file.metadata.hash)) else { return
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
