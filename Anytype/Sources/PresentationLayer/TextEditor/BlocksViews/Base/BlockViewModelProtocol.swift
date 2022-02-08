import UIKit
import BlocksModels

protocol BlockViewModelProtocol:
    HashableProvier,
    ContentConfigurationProvider,
    BlockDataProvider,
    BlockFocusing
{
    func didSelectRowInTableView()
}

protocol HashableProvier {
    var hashable: AnyHashable { get }
}

protocol ContentConfigurationProvider {
    var indentationLevel: Int { get }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration
}

protocol BlockFocusing {
    func set(focus: BlockFocusPosition)
}

extension BlockFocusing {
    func set(focus: BlockFocusPosition) { }
}

protocol BlockDataProvider {
    var information: BlockInformation { get }
}

// MARK: - Extensions

extension BlockDataProvider {
    var blockId: BlockId { information.id }
    var content: BlockContent { information.content }
}
