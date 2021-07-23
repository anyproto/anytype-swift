import UIKit
import Combine
import BlocksModels

class BlockFileView: UIView & UIContentView {
    private var currentConfiguration: BlockFileConfiguration
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let configuration = newValue as? BlockFileConfiguration else { return }
            guard self.currentConfiguration != configuration else { return }
            self.currentConfiguration = configuration
            
            handleNewFile(currentConfiguration.fileData)
        }
    }
    
    init(configuration: BlockFileConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        
        setupUIElements()
        handleNewFile(configuration.fileData)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI Elements
    private func setupUIElements() {
        translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(fileView)
        
        heightAnchor.constraint(equalToConstant: 48).isActive = true
        fileView.edgesToSuperview(insets: UIEdgeInsets(top: 9, left: 20, bottom: 9, right: 20))
    }
    
    func handleNewFile(_ file: BlockFile) {
        assert(file.state == .done, "Wrong state \(file.state) for block file")
        
        let data = BlockFileMediaData(
            size: FileSizeConverter.convert(size: Int(file.metadata.size)),
            name: file.metadata.name,
            typeIcon: BlockFileIconBuilder.convert(mime: file.metadata.mime)
        )
        fileView.handleNewData(data: data)
    }
    
    // MARK:- Views
    
    private let fileView: BlockFileMediaView = BlockFileMediaView()
}
