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
        addSubview(emptyView)
        
        heightAnchor.constraint(equalToConstant: 48).isActive = true
        emptyView.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        fileView.edgesToSuperview(insets: UIEdgeInsets(top: 9, left: 20, bottom: 9, right: 20))
    }
    
    func handleNewFile(_ file: BlockFile) {
        switch file.state  {
        case .empty:
            emptyView.change(state: .empty)

            fileView.isHidden = true
            emptyView.isHidden = false
        case .uploading:
            emptyView.change(state: .uploading)

            fileView.isHidden = true
            emptyView.isHidden = false
        case .error:
            emptyView.change(state: .error)

            fileView.isHidden = true
            emptyView.isHidden = false
        case .done:
            let data = BlockFileMediaData(
                size: FileSizeConverter.convert(size: Int(file.metadata.size)),
                name: file.metadata.name,
                typeIcon: BlockFileIconBuilder.convert(mime: file.metadata.mime)
            )
            fileView.handleNewData(data: data)
            
            fileView.isHidden = false
            emptyView.isHidden = true
        }
    }
    
    // MARK:- Views
    
    private let fileView: BlockFileMediaView = BlockFileMediaView()
    
    private let emptyView: BlocksFileEmptyView = {
        let view = BlocksFileEmptyView(
            configuration: BlocksFileEmptyViewConfiguration(
                image: UIImage.blockFile.empty.file,
                text: "Upload a file"
            )
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}
