import UIKit
import BlocksModels
import AnytypeCore


struct RelationBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation

    let relationValue: RelationValue
    let actionOnValue: (() -> Void)?

    // MARK: - BlockViewModelProtocol methods

    var hashable: AnyHashable {
        [
            info,
            relationValue
        ] as [AnyHashable]
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        return RelationBlockContentConfiguration(
            actionOnValue: { _ in actionOnValue?() },
            relation: RelationItemModel(relationValue: relationValue)
        ).cellBlockConfiguration(
            indentationSettings: .init(with: info.configurationData),
            dragConfiguration: .init(id: info.id)
        )
    }
    
}
