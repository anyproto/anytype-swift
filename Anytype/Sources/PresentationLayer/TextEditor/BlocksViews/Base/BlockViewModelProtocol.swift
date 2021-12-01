import UIKit
import BlocksModels

protocol BlockViewModelProtocol:
    ContextualMenuHandler,
    HashableProvier,
    ContentConfigurationProvider,
    BlockDataProvider
{
    func didSelectRowInTableView()
    var indentationLevel: Int { get }
    /// Block that upper than current.
    /// Upper block can has other parent (i.e. has different level) but must be followed by the current block.
    var upperBlock: BlockModelProtocol? { get }
}

protocol ContextualMenuHandler {
    func makeContextualMenu() -> [ContextualMenu]
    func handle(action: ContextualMenu)
}

protocol HashableProvier {
    var hashable: AnyHashable { get }
}

protocol ContentConfigurationProvider {
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration
}

protocol BlockDataProvider {
    var information: BlockInformation { get }
}

// MARK: - Extensions

extension BlockDataProvider {
    var blockId: BlockId { information.id }
    var content: BlockContent { information.content }
}
