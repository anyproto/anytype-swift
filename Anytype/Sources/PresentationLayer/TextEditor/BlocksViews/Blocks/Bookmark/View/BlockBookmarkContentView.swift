import UIKit
import Combine
import BlocksModels

    
final class BlockBookmarkContentView: UIView & UIContentView {
    private let containerView = BlockBookmarkContainerView()
    
    private var currentConfiguration: BlockBookmarkConfiguration
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
        containerView.apply(state: bookmark.blockBookmarkState)
    }
}
