import UIKit
import BlocksModels

protocol BlockViewModelProtocol: ContextualMenuHandler, DiffableProvier, ContentConfigurationProvider, BlockDataProvider {
    func didSelectRowInTableView()
    func updateView()
    var indentationLevel: Int { get }
}

protocol ContextualMenuHandler {
    func makeContextualMenu() -> ContextualMenu
    func handle(contextualMenuAction: ContextualMenuAction)
}

protocol DiffableProvier {
    var diffable: AnyHashable { get }
}

protocol ContentConfigurationProvider {
    func makeContentConfiguration() -> UIContentConfiguration
}

protocol BlockDataProvider {
    var blockId: BlockId { get }
    var content: BlockContent { get }
    var information: BlockInformation { get }
}


extension BlockViewModelProtocol {
    func contextMenuInteraction() -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (value) -> UIMenu? in
            let menu = self.makeContextualMenu()

            let uiActions = menu.children.map { action -> UIAction in
                let identifier = UIAction.Identifier(action.identifier)

                let action = UIAction(title: action.title, image: action.image, identifier: identifier, state: .off) { action in
                    if let identifier = ContextualMenuIdentifierBuilder.action(for: action.identifier.rawValue) {
                        self.handle(contextualMenuAction: identifier)
                    }
                }
                return action
            }
            return UIMenu(title: menu.title, children: uiActions)
        }
    }
}
