import BlocksModels
import UIKit

final class ObjectHeaderBuilder {
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
    
    init(settingsViewModel: ObjectSettingsViewModel, router: EditorRouterProtocol) {
        self.settingsViewModel = settingsViewModel
        self.router = router
    }
    
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
        
        return header.modifiedByLocalEvent(event, onIconTap: onIconTap, onCoverTap: onCoverTap) ?? .empty
    }
    
    private func fakeHeader(event: ObjectHeaderLocalEvent) -> ObjectHeader {
        switch event {
        case .iconUploading(let uIImage):
            return ObjectHeader.iconOnly(
                .preview(.basic(uIImage), .left)
            )
        case .coverUploading(let uIImage):
            return ObjectHeader.coverOnly(
                ObjectCover(state: .preview(uIImage), onTap: onCoverTap)
            )
        }
    }
    
    private func buildObjectHeader(details: DetailsDataProtocol) -> ObjectHeader {
        let layoutAlign = details.layoutAlign ?? .left
        
        if let icon = details.icon, let cover = details.documentCover {
            return .iconAndCover(
                icon: .icon(icon, layoutAlign),
                cover: ObjectCover(
                    state:  .cover(cover),
                    onTap: onCoverTap
                )
            )
        }
        
        if let icon = details.icon {
            return .iconOnly(
                .icon(icon, layoutAlign)
            )
        }
        
        if let cover = details.documentCover {
            return .coverOnly(ObjectCover(state: .cover(cover), onTap: onCoverTap))
        }
        
        return .empty
    }
}
