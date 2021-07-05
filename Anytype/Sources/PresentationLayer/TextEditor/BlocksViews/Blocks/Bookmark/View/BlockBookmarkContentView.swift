import UIKit
import Combine
import BlocksModels

    
final class BlockBookmarkContentView: UIView & UIContentView {
    private let containerView = BlockBookmarkContainerView()
    
    private var imageSubscription: AnyCancellable?
    private var iconSubscription: AnyCancellable?
    
    private var currentConfiguration: BlockBookmarkConfiguration
    private var imageLoader: BookmarkImageLoader?
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let configuration = newValue as? BlockBookmarkConfiguration,
                  configuration != currentConfiguration else { return }
            
            currentConfiguration = configuration
            onDataUpdate(bookmark: currentConfiguration.bookmarkData)
        }
    }
    
    init(configuration: BlockBookmarkConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        setup()
        
        onDataUpdate(bookmark: currentConfiguration.bookmarkData)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
            
    private func setup() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        containerView.pinAllEdges(to: self, insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -20))
    }
    
    private func onDataUpdate(bookmark: BlockBookmark) {
        if case let .fetched(payload) = BlockBookmarkConverter.toState(bookmark) {
            self.imageLoader = BookmarkImageLoader(imageHash: payload.imageHash, iconHash: payload.iconHash)
        } else {
            self.imageLoader = nil
        }
        
        iconSubscription = imageLoader?.iconProperty?.stream.receiveOnMain().sink { [weak self] icon in
            icon.flatMap {
                self?.containerView.updateIcon(icon: $0)
            }
        }

        imageSubscription = imageLoader?.imageProperty?.stream.receiveOnMain().sink { [weak self] image in
            image.flatMap {
                self?.containerView.updateImage(image: $0)
            }
        }
        
        containerView.apply(state: BlockBookmarkConverter.toState(bookmark))
    }
}
