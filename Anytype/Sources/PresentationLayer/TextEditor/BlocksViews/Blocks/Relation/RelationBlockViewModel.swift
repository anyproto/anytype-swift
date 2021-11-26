import UIKit
import BlocksModels



class RelationBlockViewModel: BlockViewModelProtocol {
    var information: BlockInformation
    var indentationLevel: Int
    var upperBlock: BlockModelProtocol?

    var relation: Relation

    // MARK: - init

    init(information: BlockInformation, indentationLevel: Int, relation: Relation) {
        self.information = information
        self.indentationLevel = indentationLevel
        self.relation = relation
    }

    // MARK: - BlockViewModelProtocol methods

    func makeContextualMenu() -> [ContextualMenu] {
        []
    }

    func handle(action: ContextualMenu) {}

    var hashable: AnyHashable {
        [
            indentationLevel,
            information,
            relation
        ] as [AnyHashable]
    }

    func didSelectRowInTableView() {}

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        RelationBlockContentConfiguration(relation: relation)
    }
    
}
