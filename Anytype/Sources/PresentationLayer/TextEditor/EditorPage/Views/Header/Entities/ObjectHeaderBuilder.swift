import BlocksModels
import UIKit

final class ObjectHeaderBuilder {
    
    // MARK: - Private variables
    
    private lazy var onIconTap = { [weak self] in
        guard let self = self else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        self.router.showIconPicker()
    }
    
    private lazy var onCoverTap = { [weak self] in
        guard let self = self else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        self.router.showCoverPicker()
    }
    
    private let router: EditorRouterProtocol
    
    // MARK: - Initializers
    
    init(router: EditorRouterProtocol) {
        self.router = router
    }
    
    func header(details: ObjectDetails?) -> ObjectHeader {
        guard let details = details else {
            return .empty(ObjectHeaderEmptyData(onTap: onCoverTap))
        }
        return buildObjectHeader(details: details)
    }
    
    func updatedHeader(_ update: ObjectHeaderUpdate, details: ObjectDetails?) -> ObjectHeader {
        guard let details = details else {
            return fakeHeader(update: update)
        }
        
        let header = buildObjectHeader(details: details)
        
        return header.modifiedByUpdate(
            update,
            onIconTap: onIconTap,
            onCoverTap: onCoverTap
        ) ?? .empty(ObjectHeaderEmptyData(onTap: onCoverTap))
    }
    
    // MARK: - Private
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
        case .coverUploading(let path):
            return ObjectHeader.filled(
                .coverOnly(
                    ObjectHeaderCover(
                        coverType: .preview(UIImage(contentsOfFile: path)),
                        onTap: onCoverTap
                    )
                )
            )
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
