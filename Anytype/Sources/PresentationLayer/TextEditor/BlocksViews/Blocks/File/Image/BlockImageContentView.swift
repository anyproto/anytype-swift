import UIKit
import Combine
import BlocksModels
import Kingfisher
import AnytypeCore

final class BlockImageContentView: BaseBlockView<BlockImageConfiguration> {
    
    private lazy var imageView = UIImageView()
    private lazy var tapGesture = BindableGestureRecognizer { [unowned self] _ in
        currentConfiguration.imageViewTapHandler(imageView)
    }
    private var currentFile: BlockFile?

    override func setupSubviews() {
        super.setupSubviews()
        setupUIElements()
    }

    override func update(with configuration: BlockImageConfiguration) {
        super.update(with: configuration)
        handleFile(configuration.fileData, currentFile)
    }

    override func update(with state: UICellConfigurationState) {
        super.update(with: state)

        tapGesture.isEnabled = state.isEditing
    }
    
    func setupUIElements() {
        addGestureRecognizer(tapGesture)
        #warning("Support image alignments")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .strokeTertiary
        
        addSubview(imageView) {
            $0.pinToSuperview(insets: Layout.imageViewInsets)
            $0.height.equal(to: Layout.imageContentViewDefaultHeight)
        }
    }
    
    private func handleFile(_ file: BlockFile, _ oldFile: BlockFile?) {
        anytypeAssert(
            file.state == .done,
            "Wrong state \(file.state) for block image",
            domain: .blockImage
        )
        setupImage(file, oldFile)
        invalidateIntrinsicContentSize()
    }
    
    func setupImage(_ file: BlockFile, _ oldFile: BlockFile?) {
        guard !file.metadata.hash.isEmpty else { return }

        let imageId = file.metadata.hash
        guard imageId != oldFile?.metadata.hash else { return }
        currentFile = file
        
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
            options: [.processor(DownsamplingImageProcessor(size: imageSize)), .transition(.fade(0.2))]
        )
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
