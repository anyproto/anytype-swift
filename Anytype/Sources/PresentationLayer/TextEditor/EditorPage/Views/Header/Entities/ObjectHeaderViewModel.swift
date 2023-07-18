import Services
import UIKit
import Combine
import AnytypeCore

protocol ObjectHeaderRouterProtocol: AnyObject {
    func showIconPicker()
    func showCoverPicker()
}

final class ObjectHeaderViewModel: ObservableObject {
    
    @Published private(set) var header: ObjectHeader?

    // MARK: - Private variables
    
    private lazy var onIconTap = { [weak self] in
        guard let self = self, !self.isOpenedForPreview else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        self.router.showIconPicker()
    }
    
    private lazy var onCoverTap = { [weak self] in
        guard let self = self, !self.isOpenedForPreview else { return }
        guard self.document.details?.layoutValue != .note else { return }


        UISelectionFeedbackGenerator().selectionChanged()

        self.router.showCoverPicker()
    }
    
    private let document: BaseDocumentGeneralProtocol
    private let router: ObjectHeaderRouterProtocol
    
    private var subscription: AnyCancellable?
    private let isOpenedForPreview: Bool
    
    // MARK: - Initializers
    
    init(document: BaseDocumentGeneralProtocol, router: ObjectHeaderRouterProtocol, isOpenedForPreview: Bool) {
        self.document = document
        self.router = router
        self.isOpenedForPreview = isOpenedForPreview
        
        setupSubscription()

        header = buildShimmeringHeader()
    }
    
    // MARK: - Private
    private func setupSubscription() {
        subscription = document.updatePublisher.sink { [weak self] update in
            self?.onUpdate(update)
        }
    }

    func buildShimmeringHeader() -> ObjectHeader {
        let usecase = ObjectIconImageUsecase.openedObject
        let imageSize = usecase.objectIconImageGuidelineSet.emojiImageGuideline?.size ?? .zero
        let image = UIImage().image(
            imageSize: imageSize,
            cornerRadius: 0,
            side: imageSize.height,
            foregroundColor: nil,
            backgroundColor: .Stroke.tertiary
        )
        return .filled(
            state: .iconAndCover(
                icon: .init(
                    icon: .init(mode: .image(image), usecase: usecase),
                    layoutAlignment: .left,
                    onTap: {}
                ),
                cover: .init(
                    coverType: .cover(.color(.Stroke.tertiary)),
                    onTap: {})
            ),
            isShimmering: true
        )
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
            return buildShimmeringHeader()
        }
        return HeaderBuilder.buildObjectHeader(details: details, usecase: .openedObject, onIconTap: onIconTap, onCoverTap: onCoverTap)
    }
    
    private func buildLoadingHeader(_ update: ObjectHeaderUpdate) -> ObjectHeader {
        guard let details = document.details else {
            return fakeHeader(update: update)
        }
        
        let header = HeaderBuilder.buildObjectHeader(details: details, usecase: .openedObject, onIconTap: onIconTap, onCoverTap: onCoverTap)
        return header.modifiedByUpdate(
            update,
            onIconTap: onIconTap,
            onCoverTap: onCoverTap
        ) ?? .empty(data: ObjectHeaderEmptyData(onTap: onCoverTap))
    }
    
    private func fakeHeader(update: ObjectHeaderUpdate) -> ObjectHeader {
        switch update {
        case .iconUploading(let path):
            return ObjectHeader.filled(state:
                .iconOnly(
                    ObjectHeaderIconOnlyState(
                        icon: ObjectHeaderIcon(
                            icon: .init(mode: .basicPreview(UIImage(contentsOfFile: path)), usecase: .openedObject),
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
                return ObjectHeader.filled(state:
                    .coverOnly(
                        ObjectHeaderCover(
                            coverType: .preview(.image(UIImage(contentsOfFile: string))),
                            onTap: onCoverTap
                        )
                    )
                )
            case .remotePreviewURL(let url):
                return ObjectHeader.filled(state:
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
}

enum HeaderBuilder {
    static func buildObjectHeader(
        details: ObjectDetails,
        usecase: ObjectIconImageUsecase,
        onIconTap: @escaping () -> Void,
        onCoverTap: @escaping () -> Void
    ) -> ObjectHeader {
        let layoutAlign = details.layoutAlignValue
        
        if details.layoutValue == .note {
            return .empty(data: .init(onTap: {}))
        }
        
        let icon = details.layoutValue == .bookmark ? nil : details.icon
        
        if let icon = icon, let cover = details.documentCover {
            return .filled(state:
                    .iconAndCover(
                        icon: ObjectHeaderIcon(
                            icon: .init(mode: .icon(icon), usecase: usecase),
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
        
        if let icon = icon {
            return .filled(state:
                    .iconOnly(
                        ObjectHeaderIconOnlyState(
                            icon: ObjectHeaderIcon(
                                icon: .init(mode: .icon(icon), usecase: usecase),
                                layoutAlignment: layoutAlign,
                                onTap: onIconTap
                            ),
                            onCoverTap: onCoverTap
                        )
                    )
            )
        }
        
        if let cover = details.documentCover {
            return .filled(state:
                    .coverOnly(
                        ObjectHeaderCover(
                            coverType: .cover(cover),
                            onTap: onCoverTap
                        )
                    )
            )
        }
        
        return .empty(data: ObjectHeaderEmptyData(onTap: onCoverTap))
    }

}
