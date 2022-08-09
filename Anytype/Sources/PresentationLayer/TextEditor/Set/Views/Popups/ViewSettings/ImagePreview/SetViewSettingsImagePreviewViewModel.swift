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
        cancellable = setModel.$dataView.sink { [weak self] _ in
            guard let self = self else { return }
            self.coverRows = self.buildCoverRows()
            self.relationsRows = self.buildRelationsRows()
        }
    }
    
    private func buildCoverRows() -> [SetViewSettingsImagePreviewRowConfiguration] {
        SetViewSettingsImagePreviewCover.allCases.map { [setModel] cover in
            SetViewSettingsImagePreviewRowConfiguration(
                id: cover.rawValue,
                iconAsset: nil,
                title: cover.title,
                isSelected: setModel.activeView.coverRelationKey == cover.rawValue,
                onTap: { [weak self] in
                    self?.onSelect(cover.rawValue)
                }
            )
        }
    }
    
    private func buildRelationsRows() -> [SetViewSettingsImagePreviewRowConfiguration] {
        let fileRelations = setModel.dataView.relations.filter {
            !$0.isHidden && $0.format == RelationMetadata.Format.file
        }
        return fileRelations.map { [setModel] relation in
            SetViewSettingsImagePreviewRowConfiguration(
                id: relation.id,
                iconAsset: relation.format.iconAsset,
                title: relation.name,
                isSelected: setModel.activeView.coverRelationKey == relation.key,
                onTap: { [weak self] in
                    self?.onSelect(relation.key)
                }
            )
        }
    }
}
