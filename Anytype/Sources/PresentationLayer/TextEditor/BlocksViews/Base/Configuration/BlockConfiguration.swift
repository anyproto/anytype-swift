import UIKit

protocol Configuration {
    associatedtype BlockConfiguration

    var configuration: BlockConfiguration { get }
    var currentConfigurationState: UICellConfigurationState? { get }
}

protocol BlockConfiguration: Hashable where View.Configuration == Self {
    associatedtype View: BlockContentView
}

extension BlockConfiguration {
    func cellBlockConfiguration(indentationSettings: IndentationSettings?) -> CellBlockConfiguration<Self> {
        CellBlockConfiguration(
            blockConfiguration: self,
            currentConfigurationState: nil,
            indentationSettings: indentationSettings
        )
    }
}
