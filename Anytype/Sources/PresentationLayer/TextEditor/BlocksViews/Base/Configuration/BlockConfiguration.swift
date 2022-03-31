import UIKit

protocol Configuration {
    associatedtype BlockConfiguration

    var configuration: BlockConfiguration { get }
    var currentConfigurationState: UICellConfigurationState? { get }
}

protocol BlockConfiguration: Hashable where View.Configuration == Self {
    associatedtype View: BlockContentView
}

struct BlockDragConfiguration {
    let id: String
}

extension BlockConfiguration {
    func cellBlockConfiguration(
        indentationSettings: IndentationSettings?,
        dragConfiguration: BlockDragConfiguration?
    ) -> CellBlockConfiguration<Self> {
        CellBlockConfiguration(
            blockConfiguration: self,
            currentConfigurationState: nil,
            indentationSettings: indentationSettings,
            dragConfiguration: dragConfiguration
        )
    }
}
