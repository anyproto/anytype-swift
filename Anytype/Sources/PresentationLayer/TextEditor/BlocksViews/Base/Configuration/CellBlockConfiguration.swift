import UIKit

protocol CellBlockConfigurationProtocol where Self: UIContentConfiguration {
    associatedtype Configuration: BlockConfiguration
}

struct CellBlockConfiguration<Configuration: BlockConfiguration>: UIContentConfiguration {
    func makeContentView() -> UIView & UIContentView {
        let contentView = EditorContentView<Configuration.View>(configuration: self)
        contentView.configuration = self
        
        return contentView
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }

        var updatedConfig = self

        updatedConfig.currentConfigurationState = state

        return updatedConfig
    }

    let blockConfiguration: Configuration
    var currentConfigurationState: UICellConfigurationState?
    let dragConfiguration: BlockDragConfiguration?
    let styleConfiguration: CellStyleConfiguration?
}
