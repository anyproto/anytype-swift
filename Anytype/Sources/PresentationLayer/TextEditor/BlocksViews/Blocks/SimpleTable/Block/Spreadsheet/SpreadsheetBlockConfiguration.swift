import UIKit
import Combine

struct SpreadsheetBlockConfiguration<Configuration: BlockConfiguration>: UIContentConfiguration {
    func makeContentView() -> UIView & UIContentView {
        SpreadsheetBlockView<Configuration.View>(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }

        var updatedConfig = self

        updatedConfig.currentConfigurationState = state

        return updatedConfig
    }

    let blockConfiguration: Configuration
    let styleConfiguration: CellStyleConfiguration
    var currentConfigurationState: UICellConfigurationState?
    let dragConfiguration: BlockDragConfiguration?
}

struct CellStyleConfiguration: Hashable {
    let backgroundColor: UIColor?
}
