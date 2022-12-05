import Combine
import BlocksModels

final class SetViewSettingsImagePreviewViewModel: ObservableObject {
    let title = Loc.Set.View.Settings.ImagePreview.title
    @Published var coverRows: [SetViewSettingsImagePreviewRowConfiguration] = []
    @Published var relationsRows: [SetViewSettingsImagePreviewRowConfiguration] = []
    
    private let onSelect: (String) -> Void
    private let setModel: EditorSetViewModel
    private var cancellable: Cancellable?
    
    init(setModel: EditorSetViewModel, onSelect: @escaping (String) -> Void) {
        self.setModel = setModel
        self.onSelect = onSelect
        self.setup()
    }
    
    private func setup() {
        cancellable = setModel.$dataView.sink { [weak self] blockDataView in
            guard let self = self else { return }
            self.coverRows = self.buildCoverRows(from: blockDataView)
            self.relationsRows = self.buildRelationsRows(from: blockDataView)
        }
    }
    
    private func buildCoverRows(from blockDataView: BlockDataview) -> [SetViewSettingsImagePreviewRowConfiguration] {
        guard let activeView = activeView(from: blockDataView) else {
            return []
        }
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
    
    private func buildRelationsRows(from blockDataView: BlockDataview) -> [SetViewSettingsImagePreviewRowConfiguration] {
        guard let activeView = activeView(from: blockDataView) else {
            return []
        }
        let fileRelationDetails = setModel.dataViewRelationsDetails.filter {
            !$0.isHidden && $0.format == RelationFormat.file
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
    
    private func activeView(from blockDataView: BlockDataview) -> DataviewView? {
        blockDataView.views.first { $0.id == blockDataView.activeViewId }
    }
}
