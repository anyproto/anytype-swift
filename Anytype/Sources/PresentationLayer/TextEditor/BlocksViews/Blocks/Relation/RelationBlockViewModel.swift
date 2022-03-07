import UIKit
import BlocksModels
import AnytypeCore


class RelationBlockViewModel: BlockViewModelProtocol {
    var information: BlockInformation
    var indentationLevel: Int

    var relation: Relation
    var actionOnValue: ((_ relation: Relation) -> Void)?

    // MARK: - init

    init(information: BlockInformation, indentationLevel: Int, relation: Relation, actionOnValue: ((_ relation: Relation) -> Void)?) {
        self.information = information
        self.indentationLevel = indentationLevel
        self.relation = relation
        self.actionOnValue = actionOnValue
    }

    // MARK: - BlockViewModelProtocol methods

    var hashable: AnyHashable {
        [
            indentationLevel,
            information,
            relation
        ] as [AnyHashable]
    }

    func didSelectRowInTableView() {}

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        if FeatureFlags.uikitRelationBlock {
            return RelationBlockContentConfiguration(actionOnValue: actionOnValue, relation: relation).asCellBlockConfiguration
        }
        return DepricatedRelationBlockContentConfiguration(actionOnValue: actionOnValue, relation: relation).asCellBlockConfiguration
    }
    
}
