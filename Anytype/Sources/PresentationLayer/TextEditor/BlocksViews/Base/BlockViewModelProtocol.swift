import UIKit
import BlocksModels

protocol BlockViewModelProtocol:
    HashableProvier,
    ContentConfigurationProvider,
    BlockInformationProvider,
    BlockFocusing
{ }

protocol HashableProvier {
    var hashable: AnyHashable { get }
}

protocol ContentConfigurationProvider {
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration
}

protocol IndentationProvider {
    var indentationLevel: Int { get }
}

protocol BlockFocusing {
    func didSelectRowInTableView(editorEditingState: EditorEditingState)

    func set(focus: BlockFocusPosition)
}

extension BlockFocusing {
    func set(focus: BlockFocusPosition) { }
}

protocol BlockInformationProvider {
    var info: BlockInformation { get }
}

// MARK: - Extensions

extension BlockInformationProvider {
    var blockId: BlockId { info.id }
    var content: BlockContent { info.content }
}
