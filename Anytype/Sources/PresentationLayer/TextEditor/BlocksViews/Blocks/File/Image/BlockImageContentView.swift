import UIKit
import Combine
import Services
import Kingfisher
import AnytypeCore

final class BlockImageContentView: UIView, BlockContentView {
    private lazy var imageView = UIImageView()
    private lazy var tapGesture = BindableGestureRecognizer { [weak self] _ in
        guard let self else { return }
        imageViewTapHandler?(imageView)
    }
    private var currentFile: BlockFile?
    private var imageViewTapHandler: ((UIImageView) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIElements()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUIElements()
    }

    func update(with configuration: BlockImageConfiguration) {
        handleFile(configuration: configuration)
        imageViewTapHandler = configuration.imageViewTapHandler
    }

    func update(with state: UICellConfigurationState) {
        tapGesture.isEnabled = state.isEditing
    }
    
    func setupUIElements() {
        addGestureRecognizer(tapGesture)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .Shape.tertiary
        
        addSubview(imageView) {
            $0.pinToSuperview(insets: Layout.imageViewInsets)
            $0.height.equal(to: Layout.imageContentViewDefaultHeight)
        }
    }
    
    private func handleFile(configuration: BlockImageConfiguration) {
        anytypeAssert(
            configuration.fileData.state == .done,
            "Wrong state \(configuration.fileData.state) for block image"
        )
        setupImage(with: configuration)
    }
    
    func setupImage(with configuration: BlockImageConfiguration) {
        let file = configuration.fileData
        let oldFile = currentFile

        guard !file.metadata.targetObjectId.isEmpty else { return }

        let imageId = file.metadata.targetObjectId
        guard imageId != oldFile?.metadata.targetObjectId else { return }
        currentFile = file
                
        let imageWidth = configuration.maxWidth - Layout.imageViewInsets.right - Layout.imageViewInsets.left
        let imageSize = CGSize(width: imageWidth, height: Layout.imageContentViewDefaultHeight)
        
        let imageGuideline = ImageGuideline(size: imageSize)
        imageView.wrapper
            .imageGuideline(imageGuideline)
            .scalingType(.downsampling)
            .setImage(id: imageId)
    }
}

private extension BlockImageContentView {
    enum Layout {
        static let imageContentViewDefaultHeight: CGFloat = 250
        static let imageViewInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
}
