import UIKit
import BlocksModels
import AnytypeCore


struct RelationBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation

    let relation: Relation
    let actionOnValue: ((_ relation: Relation) -> Void)?

    // MARK: - BlockViewModelProtocol methods

    var hashable: AnyHashable {
        [
            info,
            relation
        ] as [AnyHashable]
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        if FeatureFlags.uikitRelationBlock {
            return RelationBlockContentConfiguration(
                actionOnValue: actionOnValue, relation: relation
            ).cellBlockConfiguration(indentationSettings: .init(with: info.metadata))
        }
        return DepricatedRelationBlockContentConfiguration(
            actionOnValue: actionOnValue, relation: relation
        ).cellBlockConfiguration(indentationSettings: .init(with: info.metadata))
    }
    
}
