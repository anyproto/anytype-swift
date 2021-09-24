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
    
    func objectHeader(details: DetailsDataProtocol?) -> ObjectHeader {
        guard let details = details else {
            return .empty
        }
        return buildObjectHeader(details: details)
    }
    
    func objectHeaderForLocalEvent(details: DetailsDataProtocol?, event: ObjectHeaderLocalEvent) -> ObjectHeader {
        guard let details = details else {
            return fakeHeader(event: event)
        }
        
        let header = buildObjectHeader(details: details)
        
        return header.modifiedByLocalEvent(
            event,
            onIconTap: onIconTap,
            onCoverTap: onCoverTap
        ) ?? .empty
    }
    
    private func fakeHeader(event: ObjectHeaderLocalEvent) -> ObjectHeader {
        switch event {
        case .iconUploading(let uIImage):
            return ObjectHeader.iconOnly(
                ObjectHeaderIcon(
                    icon: .basicPreview(uIImage),
                    layoutAlignment: .left,
                    onTap: onIconTap
                )
            )
        case .coverUploading(let uIImage):
            return ObjectHeader.coverOnly(
                .preview(uIImage)
            )
        }
    }
    
    private func buildObjectHeader(details: DetailsDataProtocol) -> ObjectHeader {
        let layoutAlign = details.layoutAlign ?? .left
        
        if let icon = details.icon, let cover = details.documentCover {
            return .iconAndCover(
                icon: ObjectHeaderIcon(
                    icon: .icon(icon),
                    layoutAlignment: layoutAlign,
                    onTap: onIconTap
                ),
                cover: .cover(cover)
            )
        }
        
        if let icon = details.icon {
            return .iconOnly(
                ObjectHeaderIcon(
                    icon: .icon(icon),
                    layoutAlignment: layoutAlign,
                    onTap: onIconTap
                )
            )
        }
        
        if let cover = details.documentCover {
            return .coverOnly(.cover(cover))
        }
        
        return .empty
    }
}
