import UIKit
import Combine
import BlocksModels
import Kingfisher
import AnytypeCore

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
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .grayscale10
        
        addImageViewLayout()
    }
    
    /// MARK: - EditorModuleDocumentViewCellContentConfigurationsCellsListenerProtocol
    private func refreshImage() {
        handleFile(currentConfiguration.fileData, .none)
    }
    
    private func handleFile(_ file: BlockFile, _ oldFile: BlockFile?) {
        anytypeAssert(file.state == .done, "Wrong state \(file.state) for block image")
        setupImage(file, oldFile)
        invalidateIntrinsicContentSize()
    }
    
    private func addImageViewLayout() {
        addSubview(imageView) {
            $0.pinToSuperview(insets: Layout.imageViewInsets)
            self.imageContentViewHeight = $0.height.equal(to: Layout.imageContentViewDefaultHeight)
        }
    }
    
    func setupImage(_ file: BlockFile, _ oldFile: BlockFile?) {
        guard !file.metadata.hash.isEmpty else { return }
        let imageId = file.metadata.hash
        guard imageId != oldFile?.metadata.hash else { return }
        
        imageView.kf.cancelDownloadTask()
        
        let imageWidth = currentConfiguration.maxWidth - Layout.imageViewInsets.right - Layout.imageViewInsets.left
        let imageSize = CGSize(
            width: imageWidth,
            height: Layout.imageContentViewDefaultHeight
        )
        
        let placeholder = PlaceholderImageBuilder.placeholder(
            with: ImageGuideline(size: imageSize),
            color: UIColor.grayscale10
        )
        
        imageView.kf.setImage(
            with: UrlResolver.resolvedUrl(.image(id: imageId, width: .default)),
            placeholder: placeholder,
            options: [.processor(DownsamplingImageProcessor(size: imageSize))]
        )
    }
    
}

private extension BlockImageContentView {
    enum Layout {
        static let imageContentViewDefaultHeight: CGFloat = 250
        static let imageViewTop: CGFloat = 4
        static let imageViewInsets = UIEdgeInsets(top: 10, left: 20, bottom: -10, right: -20)
    }
}
