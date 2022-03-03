import UIKit
import BlocksModels
import AnytypeCore


class RelationBlockViewModel: BlockViewModelProtocol {
    var information: BlockInformation

    var relation: Relation
    var actionOnValue: ((_ relation: Relation) -> Void)?

    // MARK: - init

    init(information: BlockInformation, relation: Relation, actionOnValue: ((_ relation: Relation) -> Void)?) {
        self.information = information
        self.relation = relation
        self.actionOnValue = actionOnValue
    }

    // MARK: - BlockViewModelProtocol methods

    var hashable: AnyHashable {
        [
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
