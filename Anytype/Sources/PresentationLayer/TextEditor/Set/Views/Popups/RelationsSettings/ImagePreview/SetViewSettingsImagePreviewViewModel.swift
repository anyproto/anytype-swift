import Combine
import Services

final class SetViewSettingsImagePreviewViewModel: ObservableObject {
    let title = Loc.Set.View.Settings.ImagePreview.title
    @Published var coverRows: [SetViewSettingsImagePreviewRowConfiguration] = []
    @Published var relationsRows: [SetViewSettingsImagePreviewRowConfiguration] = []
    
    private let setDocument: any SetDocumentProtocol
    private let onSelect: (String) -> Void
    private var cancellable: (any Cancellable)?
    
    init(setDocument: some SetDocumentProtocol, onSelect: @escaping (String) -> Void) {
        self.setDocument = setDocument
        self.onSelect = onSelect
        self.setup()
    }
    
    private func setup() {
        cancellable = setDocument.activeViewPublisher.sink { [weak self] activeView in
            guard let self = self else { return }
            self.coverRows = self.buildCoverRows(from: activeView)
            self.relationsRows = self.buildRelationsRows(from: activeView)
        }
    }
    
    private func buildCoverRows(from activeView: DataviewView) -> [SetViewSettingsImagePreviewRowConfiguration] {
        return SetViewSettingsImagePreviewCover.allCases.map { cover in
            SetViewSettingsImagePreviewRowConfiguration(
                id: cover.rawValue,
                iconAsset: nil,
                title: cover.title,
                isSelected: activeView.coverRelationKey == cover.rawValue,
                onTap: { [weak self] in
                    self?.onSelect(cover.rawValue)
                }
            )
        }
    }
    
    private func buildRelationsRows(from activeView: DataviewView) -> [SetViewSettingsImagePreviewRowConfiguration] {
        let fileRelationDetails = setDocument.dataViewRelationsDetails.filter {
            !$0.isHidden && $0.format == PropertyFormat.file
        }
        return fileRelationDetails.map { relationDetails in
            SetViewSettingsImagePreviewRowConfiguration(
                id: relationDetails.id,
                iconAsset: relationDetails.format.iconAsset,
                title: relationDetails.name,
                isSelected: activeView.coverRelationKey == relationDetails.key,
                onTap: { [weak self] in
                    self?.onSelect(relationDetails.key)
                }
            )
        }
    }
}
