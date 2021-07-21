
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
            guard let configuration = newValue as? VideoBlockConfiguration else { return }
            apply(configuration: configuration)
        }
    }
    private var currentConfiguration: VideoBlockConfiguration
    private lazy var videoVC = AVPlayerViewController()
    private lazy var emptyView: BlocksFileEmptyView = {
        let view = BlocksFileEmptyView(
            viewData: .init(image: UIImage.blockFile.empty.video, placeholderText: "Upload a video")
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(configuration: VideoBlockConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        self.setup()
        switch currentConfiguration.file.state {
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
        switch currentConfiguration.file.state {
        case .error, .empty, .uploading:
            self.addEmptyViewAndRemoveVideoView()
        case .done:
            self.addVideoViewAndRemoveEmptyView()
        }
    }
    
    private func addVideoViewAndRemoveEmptyView() {
        emptyView.removeFromSuperview()
        addSubview(videoVC.view)
        videoVC.view.edgesToSuperview(insets: Constants.videoViewInsets)
        videoVC.view.heightAnchor.constraint(equalToConstant: Constants.videoViewHeight).isActive = true
        
        setVideoURL()
    }
    
    private func setVideoURL() {
        guard
            let url = UrlResolver.resolvedUrl(.file(id: currentConfiguration.file.metadata.hash))
        else { return }
        
        videoVC.player = .init(url: url)
    }
    
    private func addEmptyViewAndRemoveVideoView() {
        self.videoVC.view.removeFromSuperview()
        self.addSubview(self.emptyView)
        self.emptyView.edgesToSuperview(insets: Constants.emptyViewInsets)
        self.emptyView.heightAnchor.constraint(equalToConstant: Constants.emptyViewHeight).isActive = true
        self.changeEmptyViewState()
    }
    
    private func changeEmptyViewState() {
        switch currentConfiguration.file.state {
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
    
    private func apply(configuration: VideoBlockConfiguration) {
        guard self.currentConfiguration != configuration else { return }
        let oldConfiguration = self.currentConfiguration
        self.currentConfiguration = configuration
        self.applyNewConfiguration(oldState: oldConfiguration.file.state)
    }
    
    private func applyNewConfiguration(oldState: BlockFileState) {
        switch (oldState, currentConfiguration.file.state) {
        case (.done, .done):
            setVideoURL()
        case (.done, _):
            addEmptyViewAndRemoveVideoView()
        case (_, .done):
            addVideoViewAndRemoveEmptyView()
        default:
            changeEmptyViewState()
        }
    }
}
