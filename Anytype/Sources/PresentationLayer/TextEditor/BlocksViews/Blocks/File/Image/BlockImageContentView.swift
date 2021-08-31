import UIKit
import Combine
import BlocksModels
import Kingfisher
import AnytypeCore

final class BlockImageContentView: UIView & UIContentView {
    
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
    
    func setupUIElements() {
        // TODO: Support alignments than looks beautiful
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .grayscale10
        
        addSubview(imageView) {
            $0.pinToSuperview(insets: Layout.imageViewInsets)
            $0.height.equal(to: Layout.imageContentViewDefaultHeight)
        }
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
    
    func setupImage(_ file: BlockFile, _ oldFile: BlockFile?) {
        guard !file.metadata.hash.isEmpty else { return }
        
        // TODO: Support alignments that does not look ugly
        imageView.contentMode = .center // currentConfiguration.alignment.asContentMode

        let imageId = file.metadata.hash
        guard imageId != oldFile?.metadata.hash else { return }
        
        imageView.kf.cancelDownloadTask()
        
        let imageWidth = currentConfiguration.maxWidth - Layout.imageViewInsets.right - Layout.imageViewInsets.left
        let imageSize = CGSize(
            width: imageWidth,
            height: Layout.imageContentViewDefaultHeight
        )
        
        let placeholder = ImageBuilder(
            ImageGuideline(size: imageSize)
        ).build()
        
        imageView.kf.setImage(
            with: ImageID(id: imageId, width: imageSize.width.asImageWidth).resolvedUrl,
            placeholder: placeholder,
            options: [.processor(DownsamplingImageProcessor(size: imageSize))]
        )
    }
    
    // MARK: - Unavailable
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BlockImageContentView {
    enum Layout {
        static let imageContentViewDefaultHeight: CGFloat = 250
        static let imageViewInsets = UIEdgeInsets(top: 10, left: 20, bottom: -10, right: -20)
    }
}

private extension LayoutAlignment {
    
    var asContentMode: UIView.ContentMode {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        }
    }
    
}
