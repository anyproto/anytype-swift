import UIKit
import Combine
import Services

struct BlockFileMediaData: Hashable {
    let targetObjectId: String
    let documentId: String
    let spaceId: String
}

final class BlockFileView: UIView, BlockContentView {

    @Injected(\.openedDocumentProvider)
    private var documentService: any OpenedDocumentsProviderProtocol
    
    private var document: (any BaseDocumentProtocol)?
    private var targetObjectId: String?
    private var cancellable: AnyCancellable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func update(with configuration: BlockFileConfiguration) {
       if document?.objectId != configuration.data.documentId {
           document = documentService.document(objectId: configuration.data.documentId, spaceId: configuration.data.spaceId)
        }
        
        if targetObjectId != configuration.data.targetObjectId {
            targetObjectId = configuration.data.targetObjectId
            cancellable = document?.targetDetailsPublisher(targetObjectId: configuration.data.targetObjectId)
                .sinkOnMain { [weak self] fileDetails in
                    self?.handle(fileDetails: fileDetails)
                }
        }
    }

    func setup() {
        layoutUsing.anchors { $0.height.equal(to: 32) }
        addSubview(contentView) {
            $0.pinToSuperview()
        }
    
        contentView.layoutUsing.stack {
            $0.hStack(
                $0.hGap(fixed: 3),
                imageView,
                $0.hGap(fixed: 7),
                titleView,
                $0.hGap(fixed: 10),
                sizeView,
                $0.hGap()
            )
        }
        
        imageView.layoutUsing.anchors {
            $0.width.equal(to: 18)
        }
        
        translatesAutoresizingMaskIntoConstraints = true
    }
    
    // MARK: - Private
    
    private func handle(fileDetails: FileDetails) {
        titleView.text = fileDetails.fileName
        let icon = FileIconBuilder.convert(mime: fileDetails.fileMimeType, fileName: fileDetails.fileName)
        imageView.image = UIImage(asset: icon)
        sizeView.text = ByteCountFormatter.fileFormatter.string(fromByteCount: Int64(fileDetails.sizeInBytes))
    }
    
    // MARK: - Views
    let contentView = UIView()
    
    let imageView: UIImageView  = {
        let view = UIImageView()
        view.contentMode = .center
        return view
    }()
    
    let titleView: UILabel = {
        let view = UILabel()
        view.font = .bodyRegular
        view.textColor = .Text.primary
        return view
    }()
    
    let sizeView: UILabel = {
        let view = UILabel()
        view.font = .calloutRegular
        view.textColor = .Text.secondary
        return view
    }()
}
