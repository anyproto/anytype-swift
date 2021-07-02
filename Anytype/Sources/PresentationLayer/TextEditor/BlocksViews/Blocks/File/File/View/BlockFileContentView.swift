import UIKit
import BlocksModels

final class BlockFileContentView: UIView & UIContentView {
    
    private enum Constants {
        static let topViewContentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -20)
    }
    
    private let topView = BlockFileView()
    
    private var currentConfiguration: BlockFileConfiguration
    
    var configuration: UIContentConfiguration {
        get { self.currentConfiguration }
        set {
            guard let configuration = newValue as? BlockFileConfiguration else { return }
            guard self.currentConfiguration != configuration else { return }
            applyNewConfiguration()
        }
    }
    
    init(configuration: BlockFileConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        setup()
        applyNewConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
            
    private func setup() {
        topView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topView)
        topView.pinAllEdges(to: self, insets: Constants.topViewContentInsets)
    }
    
    private func handle(_ value: BlockFile) {
        switch value.contentType {
        case .file: self.topView.apply(value)
        default: return
        }
    }
    
    private func applyNewConfiguration() {
        switch self.currentConfiguration.information.content {
        case let .file(value):
            handle(value)
        default:
            return
        }
    }
}
