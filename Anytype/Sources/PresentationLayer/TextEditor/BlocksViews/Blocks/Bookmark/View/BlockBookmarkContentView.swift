import UIKit
import Combine
import BlocksModels

    
final class BlockBookmarkContentView: UIView & UIContentView {
    
    private enum Constants {
        static let topViewInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -20)
    }
    
    private let topView = BlockBookmarkContainerView()
    private var imageSubscription: AnyCancellable?
    private var iconSubscription: AnyCancellable?
    private var currentConfiguration: BlockBookmarkConfiguration
    var configuration: UIContentConfiguration {
        get { self.currentConfiguration }
        set {
            guard let configuration = newValue as? BlockBookmarkConfiguration,
                  configuration != currentConfiguration else { return }
            currentConfiguration = configuration
            handle(currentConfiguration.bookmarkData)
        }
    }
    
    init(configuration: BlockBookmarkConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        setup()
        handle(currentConfiguration.bookmarkData)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
            
    private func setup() {
        topView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topView)
        topView.pinAllEdges(to: self, insets: Constants.topViewInsets)
    }
    
    private func handle(_ value: BlockBookmarkResource?) {
        value?.imageLoader = currentConfiguration.imageLoader
        self.topView.apply(value)
    }
    
    private func handle(_ value: BlockBookmark) {
        if self.iconSubscription.isNil {
            let item = currentConfiguration.imageLoader.iconProperty?.stream.receiveOnMain().sink(receiveValue: { [value, weak self] (image) in
                self?.handle(value)
            })
            self.iconSubscription = item
        }

        if self.imageSubscription.isNil {
            let item = currentConfiguration.imageLoader.imageProperty?.stream.receiveOnMain().sink(receiveValue: { [value, weak self] (image) in
                self?.handle(value)
            })
            self.imageSubscription = item
        }
        
        let model = BlockBookmarkConverter.asResource(value)
        self.handle(model)
    }
}
