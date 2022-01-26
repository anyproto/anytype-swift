import UIKit
import BlocksModels

protocol BlockViewModelProtocol:
    HashableProvier,
    ContentConfigurationProvider,
    BlockDataProvider
{
    func didSelectRowInTableView()
    /// Block that upper than current.
    /// Upper block can has other parent (i.e. has different level) but must be followed by the current block.
    var upperBlock: BlockModelProtocol? { get }
}

protocol HashableProvier {
    var hashable: AnyHashable { get }
}

protocol ContentConfigurationProvider {
    var indentationLevel: Int { get }

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
