import UIKit

private enum Constants {
    static let edges = UIEdgeInsets(top: 9, left: 12, bottom: -9, right: -12)
}

struct SpreadSheetBlockConfiguration<Configuration: BlockConfiguration>: UIContentConfiguration {
    func makeContentView() -> UIView & UIContentView {
        SpreadsheetView<Configuration.View>(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }

        var updatedConfig = self

        updatedConfig.currentConfigurationState = state

        return updatedConfig
    }

    let edgesInsets = Constants.edges
    let blockConfiguration: Configuration
    var currentConfigurationState: UICellConfigurationState?
    let dragConfiguration: BlockDragConfiguration?
}
