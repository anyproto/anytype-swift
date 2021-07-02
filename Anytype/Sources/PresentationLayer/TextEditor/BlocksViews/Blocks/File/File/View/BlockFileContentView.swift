import UIKit
import BlocksModels

final class BlockFileContentView: UIView & UIContentView {
    private let fileView: BlockFileView
    
    private var currentConfiguration: BlockFileConfiguration
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let configuration = newValue as? BlockFileConfiguration else { return }
            guard self.currentConfiguration != configuration else { return }
            self.currentConfiguration = configuration
            fileView.handle(currentConfiguration.fileData)
        }
    }
    
    init(configuration: BlockFileConfiguration) {
        self.fileView = BlockFileView(fileData: configuration.fileData)
        self.currentConfiguration = configuration
        
        super.init(frame: .zero)
        
        setup()
        
        fileView.handle(currentConfiguration.fileData)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
            
    private func setup() {
        addSubview(fileView)
        fileView.pinAllEdges(to: self, insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -20))
    }
}
