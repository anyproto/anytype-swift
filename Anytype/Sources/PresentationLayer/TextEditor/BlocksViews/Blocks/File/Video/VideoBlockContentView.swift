
import AVKit
import Combine
import UIKit
import BlocksModels

/// View model for video block
final class VideoBlockContentView: UIView, UIContentView {
    
    private enum Constants {
        static let emptyViewHeight: CGFloat = 52
        static let videoViewHeight: CGFloat = 250
        static let videoViewInsets: UIEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 20)
        static let emptyViewInsets: UIEdgeInsets = .init(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    var configuration: UIContentConfiguration {
        get {
            self.currentConfiguration
        }
        set {
            guard let configuration = newValue as? VideoBlockContentViewConfiguration else { return }
            self.apply(configuration: configuration)
        }
    }
    private var currentConfiguration: VideoBlockContentViewConfiguration
    private lazy var videoVC: AVPlayerViewController = .init()
    private lazy var emptyView: BlocksFileEmptyView = {
        let view = BlocksFileEmptyView(
            viewData: .init(image: UIImage.blockFile.empty.video, placeholderText: "Upload a video")
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(configuration: VideoBlockContentViewConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        self.setup()
        switch self.currentConfiguration.state {
        case .done:
            self.addVideoViewAndRemoveEmptyView()
        case .error, .empty, .uploading:
            self.addEmptyViewAndRemoveVideoView()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        switch self.currentConfiguration.state {
        case .error, .empty, .uploading:
            self.addEmptyViewAndRemoveVideoView()
        case .done:
            self.addVideoViewAndRemoveEmptyView()
        }
    }
    
    private func addVideoViewAndRemoveEmptyView() {
        self.emptyView.removeFromSuperview()
        self.addSubview(self.videoVC.view)
        self.videoVC.view.edgesToSuperview(insets: Constants.videoViewInsets)
        self.videoVC.view.heightAnchor.constraint(equalToConstant: Constants.videoViewHeight).isActive = true
        
        self.setVideoURL()
    }
    
    private func setVideoURL() {
        URLResolver().obtainFileURL(fileId: self.currentConfiguration.metadata.hash) { [weak self] url in
            guard let url = url else { return }
            
            self?.videoVC.player = .init(url: url)
        }
    }
    
    private func addEmptyViewAndRemoveVideoView() {
        self.videoVC.view.removeFromSuperview()
        self.addSubview(self.emptyView)
        self.emptyView.edgesToSuperview(insets: Constants.emptyViewInsets)
        self.emptyView.heightAnchor.constraint(equalToConstant: Constants.emptyViewHeight).isActive = true
        self.changeEmptyViewState()
    }
    
    private func changeEmptyViewState() {
        switch self.currentConfiguration.state {
        case .empty:
            self.emptyView.change(state: .empty)
        case .error:
            self.emptyView.change(state: .error)
        case .uploading:
            self.emptyView.change(state: .uploading)
        case .done:
            return
        }
    }
    
    private func apply(configuration: VideoBlockContentViewConfiguration) {
        guard self.currentConfiguration != configuration else { return }
        let oldConfiguration = self.currentConfiguration
        self.currentConfiguration = configuration
        self.applyNewConfiguration(oldState: oldConfiguration.state)
    }
    
    private func applyNewConfiguration(oldState: BlockFileState) {
        switch (oldState, self.currentConfiguration.state) {
        case (.done, .done):
            self.setVideoURL()
        case (.done, _):
            self.addEmptyViewAndRemoveVideoView()
        case (_, .done):
            self.addVideoViewAndRemoveEmptyView()
        default:
            self.changeEmptyViewState()
        }
    }
}
