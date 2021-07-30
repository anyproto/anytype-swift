import UIKit
import BlocksModels
import Combine


final class BlockPageLinkContentView: UIView & UIContentView {
    private enum LayoutConstants {
        static let insets: UIEdgeInsets = .init(top: 5, left: 20, bottom: 5, right: 20)
    }

    private let topView: BlockPageLinkUIKitView = .init()

    private var currentConfiguration: BlockPageLinkContentConfiguration
    var configuration: UIContentConfiguration {
        get { self.currentConfiguration }
        set {
            guard let configuration = newValue as? BlockPageLinkContentConfiguration else { return }
            guard currentConfiguration != configuration else { return }
            currentConfiguration = configuration
            applyNewConfiguration()
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
        topView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.topView) {
            $0.pinToSuperview(insets: LayoutConstants.insets)
        }
    }
    
    private func applyNewConfiguration() {
        topView.apply(currentConfiguration.state)
    }
}
