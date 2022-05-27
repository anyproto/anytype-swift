import BlocksModels
import UIKit
import Combine

final class ObjectHeaderViewModel: ObservableObject {
    
    @Published private(set) var header: ObjectHeader = .initialState
    
    // MARK: - Private variables
    
    private lazy var onIconTap = { [weak self] in
        guard let self = self else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        self.router.showIconPicker()
    }
    
    private lazy var onCoverTap = { [weak self] in
        guard let self = self else { return }
        guard self.document.details?.layout != .note else { return }

        UISelectionFeedbackGenerator().selectionChanged()

        self.router.showCoverPicker()
    }
    
    private let document: BaseDocumentProtocol
    private let router: EditorRouterProtocol
    
    private var subscription: AnyCancellable?
    
    // MARK: - Initializers
    
    init(document: BaseDocumentProtocol, router: EditorRouterProtocol) {
        self.document = document
        self.router = router
        self.header = buildHeader()
        
        setupSubscription()
    }
    
    // MARK: - Private
    private func setupSubscription() {
        subscription = document.updatePublisher.sink { [weak self] update in
            self?.onUpdate(update)
        }
    }
    
    private func onUpdate(_ update: DocumentUpdate) {
        switch update {
        case .details, .general:
            header = buildHeader()
        case .header(let data):
            header = buildLoadingHeader(data)
        case .blocks, .dataSourceUpdate, .syncStatus:
            break
        }
    }
    
    private func buildHeader() -> ObjectHeader {
        guard let details = document.details else {
            return .empty(ObjectHeaderEmptyData(onTap: onCoverTap))
        }
        return buildObjectHeader(details: details)
    }
    
    private func buildLoadingHeader(_ update: ObjectHeaderUpdate) -> ObjectHeader {
        guard let details = document.details else {
            return fakeHeader(update: update)
        }
        
        let header = buildObjectHeader(details: details)
        return header.modifiedByUpdate(
            update,
            onIconTap: onIconTap,
            onCoverTap: onCoverTap
        ) ?? .empty(ObjectHeaderEmptyData(onTap: onCoverTap))
    }
    
    private func fakeHeader(update: ObjectHeaderUpdate) -> ObjectHeader {
        switch update {
        case .iconUploading(let path):
            return ObjectHeader.filled(
                .iconOnly(
                    ObjectHeaderIconOnlyState(
                        icon: ObjectHeaderIcon(
                            icon: .basicPreview(UIImage(contentsOfFile: path)),
                            layoutAlignment: .left,
                            onTap: onIconTap
                        ),
                        onCoverTap: onCoverTap
                    )
                )
            )
        case .coverUploading(let coverUpdate):
            switch coverUpdate {
            case .bundleImagePath(let string):
                return ObjectHeader.filled(
                    .coverOnly(
                        ObjectHeaderCover(
                            coverType: .preview(.image(UIImage(contentsOfFile: string))),
                            onTap: onCoverTap
                        )
                    )
                )
            case .remotePreviewURL(let url):
                return ObjectHeader.filled(
                    .coverOnly(
                        ObjectHeaderCover(
                            coverType: .preview(.remote(url)),
                            onTap: onCoverTap
                        )
                    )
                )
            }
        }
    }
    
    private func buildObjectHeader(details: ObjectDetails) -> ObjectHeader {
        let layoutAlign = details.layoutAlign

        if details.layout == .note {
            return .empty(.init(onTap: {}))
        }
        
        if let icon = details.icon, let cover = details.documentCover {
            return .filled(
                .iconAndCover(
                    icon: ObjectHeaderIcon(
                        icon: .icon(icon),
                        layoutAlignment: layoutAlign,
                        onTap: onIconTap
                    ),
                    cover: ObjectHeaderCover(
                        coverType: .cover(cover),
                        onTap: onCoverTap
                    )
                )
            )
        }
        
        if let icon = details.icon {
            return .filled(
                .iconOnly(
                    ObjectHeaderIconOnlyState(
                        icon: ObjectHeaderIcon(
                            icon: .icon(icon),
                            layoutAlignment: layoutAlign,
                            onTap: onIconTap
                        ),
                        onCoverTap: onCoverTap
                    )
                )
            )
        }
        
        if let cover = details.documentCover {
            return .filled(
                .coverOnly(
                    ObjectHeaderCover(
                        coverType: .cover(cover),
                        onTap: onCoverTap
                    )
                )
            )
        }
        
        return .empty(ObjectHeaderEmptyData(onTap: onCoverTap))
    }
}
