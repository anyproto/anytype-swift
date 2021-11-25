import UIKit
import BlocksModels

protocol RelationBlockViewModelProtocol: ObservableObject {
    var relation: Relation { get set }
}

class RelationBlockViewModel: BlockViewModelProtocol, RelationBlockViewModelProtocol {
    var information: BlockInformation
    var indentationLevel: Int
    var upperBlock: BlockModelProtocol?

    @Published var relation: Relation

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
        RelationBlockContentConfiguration(viewModel: self)
    }
    
}
