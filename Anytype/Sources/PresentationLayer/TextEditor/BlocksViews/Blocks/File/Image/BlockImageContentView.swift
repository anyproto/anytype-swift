import UIKit
import Combine
import BlocksModels
import Kingfisher

final class BlockImageContentView: UIView & UIContentView {
    
    private var imageContentViewHeight: NSLayoutConstraint?
    
    private let imageView = UIImageView()
    
    private var currentConfiguration: BlockImageConfiguration
    var configuration: UIContentConfiguration {
        get { self.currentConfiguration }
        set {
            guard let configuration = newValue as? BlockImageConfiguration,
                  currentConfiguration != configuration else {
                return
            }
            
            let oldConfiguration = currentConfiguration
            currentConfiguration = configuration
            
            handleFile(currentConfiguration.fileData, oldConfiguration.fileData)
        }
    }

    init(configuration: BlockImageConfiguration) {
        currentConfiguration = configuration
        super.init(frame: .zero)
        
        
        setupUIElements()
        handleFile(currentConfiguration.fileData, nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUIElements() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .grayscale10
        
        
        imageView.translatesAutoresizingMaskIntoConstraints = false

        addImageViewLayout()
    }
    
    /// MARK: - EditorModuleDocumentViewCellContentConfigurationsCellsListenerProtocol
    private func refreshImage() {
        handleFile(currentConfiguration.fileData, .none)
    }
    
    private func handleFile(_ file: BlockFile, _ oldFile: BlockFile?) {
        assert(file.state == .done, "Wrong state \(file.state) for block image")
        setupImage(file, oldFile)
        invalidateIntrinsicContentSize()
    }
    
    private func addImageViewLayout() {
        addSubview(imageView)
    
        imageContentViewHeight = imageView.heightAnchor.constraint(equalToConstant: Layout.imageContentViewDefaultHeight)
        // We need priotity here cause cell self size constraint will conflict with ours
        //                imageContentViewHeight?.priority = .init(750)
        imageContentViewHeight?.isActive = true
        imageView.pinAllEdges(to: self, insets: Layout.imageViewInsets)
    }
    
    func setupImage(_ file: BlockFile, _ oldFile: BlockFile?) {
        guard !file.metadata.hash.isEmpty else { return }
        let imageId = file.metadata.hash
        guard imageId != oldFile?.metadata.hash else { return }
        
        imageView.kf.cancelDownloadTask()
        imageView.kf.setImage(
            with: UrlResolver.resolvedUrl(.image(id: imageId, width: .default)),
            placeholder: UIImage.blockFile.noImage
        ) { [weak self] result in
            guard
                case let .success(success) = result,
                let self = self
            else { return }
            
            self.imageView.contentMode = self.isImageLong(image: success.image) ? .scaleAspectFit : .scaleAspectFill
        }
    }
    
    private func isImageLong(image: UIImage) -> Bool {
        if image.size.height / image.size.width > 3 {
            return true
        }
        
        if image.size.width / image.size.height > 3 {
            return true
        }
        
        return false
    }
}

private extension BlockImageContentView {
    enum Layout {
        static let imageContentViewDefaultHeight: CGFloat = 250
        static let imageViewTop: CGFloat = 4
        static let imageViewInsets = UIEdgeInsets(top: 10, left: 20, bottom: -10, right: -20)
    }
}
