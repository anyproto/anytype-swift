import UIKit
import BlocksModels
import AnytypeCore

protocol BlockViewModelProtocol:
    ContentConfigurationProvider,
    BlockInformationProvider
{ }

protocol HashableProvier {
    var hashable: AnyHashable { get }
}

protocol ContentConfigurationProvider: HashableProvier, BlockFocusing {
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration

    func makeSpreadsheetConfiguration() -> UIContentConfiguration
}

extension ContentConfigurationProvider {
    func makeSpreadsheetConfiguration() -> UIContentConfiguration {
        anytypeAssertionFailure(
            "This content configuration doesn't support spreadsheet",
            domain: .simpleTables
        )
        return EmptyRowConfiguration(id: "", action: {} )
            .spreadsheetConfiguration(
                dragConfiguration: nil,
                styleConfiguration: .init(backgroundColor: .Background.primary)
            )
    }
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
