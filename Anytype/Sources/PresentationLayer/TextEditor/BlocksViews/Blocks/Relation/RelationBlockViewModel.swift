import UIKit
import BlocksModels


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
        RelationBlockContentConfiguration(relation: relation, actionOnValue: actionOnValue).asCellBlockConfiguration
    }
    
}
