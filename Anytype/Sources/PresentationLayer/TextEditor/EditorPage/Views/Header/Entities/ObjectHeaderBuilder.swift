import BlocksModels
import UIKit

final class ObjectHeaderBuilder {
    
    // MARK: - Private variables
    
    private lazy var onIconTap = { [weak self] in
        guard let self = self else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        self.router.showIconPicker(viewModel: self.settingsViewModel.iconPickerViewModel)
    }
    
    private lazy var onCoverTap = { [weak self] in
        guard let self = self else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        self.router.showCoverPicker(viewModel: self.settingsViewModel.coverPickerViewModel)
    }
    
    private let router: EditorRouterProtocol
    private let settingsViewModel: ObjectSettingsViewModel
    
    // MARK: - Initializers
    
    init(settingsViewModel: ObjectSettingsViewModel, router: EditorRouterProtocol) {
        self.settingsViewModel = settingsViewModel
        self.router = router
    }
    
    // MARK: - Internal functions
    
    func objectHeader(details: ObjectDetails?) -> ObjectHeader {
        guard let details = details else {
            return .empty(ObjectHeaderEmptyData(onTap: onCoverTap))
        }
        return buildObjectHeader(details: details)
    }
    
    func objectHeaderForLocalEvent(_ event: ObjectHeaderLocalEvent, details: ObjectDetails?) -> ObjectHeader {
        guard let details = details else {
            return fakeHeader(event: event)
        }
        
        let header = buildObjectHeader(details: details)
        
        return header.modifiedByLocalEvent(
            event,
            onIconTap: onIconTap,
            onCoverTap: onCoverTap
        ) ?? .empty(ObjectHeaderEmptyData(onTap: onCoverTap))
    }
    
    private func fakeHeader(event: ObjectHeaderLocalEvent) -> ObjectHeader {
        switch event {
        case .iconUploading(let uIImage):
            return ObjectHeader.filled(
                .iconOnly(
                    ObjectHeaderIconOnlyState(
                        icon: ObjectHeaderIcon(
                            icon: .basicPreview(uIImage),
                            layoutAlignment: .left,
                            onTap: onIconTap
                        ),
                        onCoverTap: onCoverTap
                    )
                )
            )
        case .coverUploading(let uIImage):
            return ObjectHeader.filled(
                .coverOnly(
                    ObjectHeaderCover(
                        coverType: .preview(uIImage),
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
