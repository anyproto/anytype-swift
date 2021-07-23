import UIKit
import BlocksModels
import Combine


final class BlockPageLinkContentView: UIView & UIContentView {
    private enum LayoutConstants {
        static let insets: UIEdgeInsets = .init(top: 5, left: 20, bottom: 5, right: 20)
    }

    private var subscriptions: Set<AnyCancellable> = []
    private let topView: BlockPageLinkUIKitView = .init()

    private var currentConfiguration: BlockPageLinkContentConfiguration
    var configuration: UIContentConfiguration {
        get { self.currentConfiguration }
        set {
            guard let configuration = newValue as? BlockPageLinkContentConfiguration else { return }
            self.apply(configuration: configuration)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
            
    init(configuration: BlockPageLinkContentConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        self.setup()
        self.applyNewConfiguration()
    }
    
    /// Setup
    private func setup() {
        self.topView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.topView)
        self.topView.edgesToSuperview(insets: LayoutConstants.insets)
    }
    
    private func apply(configuration: BlockPageLinkContentConfiguration) {
        guard self.currentConfiguration != configuration else { return }
        self.currentConfiguration = configuration
        self.applyNewConfiguration()
    }
    
    private func applyNewConfiguration() {
        subscriptions.removeAll()
        topView.apply(currentConfiguration.state)
    }
}
