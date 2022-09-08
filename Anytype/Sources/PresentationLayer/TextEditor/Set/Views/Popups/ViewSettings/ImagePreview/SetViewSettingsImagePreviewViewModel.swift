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
        let fileRelations = setModel.relationDetails.filter {
            !$0.isHidden && $0.format == RelationFormat.file
        }
        return fileRelations.map { relation in
            SetViewSettingsImagePreviewRowConfiguration(
                id: relation.id,
                iconAsset: relation.format.iconAsset,
                title: relation.name,
                isSelected: activeView.coverRelationKey == relation.key,
                onTap: { [weak self] in
                    self?.onSelect(relation.key)
                }
            )
        }
    }
    
    private func activeView(from blockDataView: BlockDataview) -> DataviewView? {
        blockDataView.views.first { $0.id == blockDataView.activeViewId }
    }
}
