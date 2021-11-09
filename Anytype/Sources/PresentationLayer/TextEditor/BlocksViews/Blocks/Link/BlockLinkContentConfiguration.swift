import UIKit
import BlocksModels


struct BlockLinkContentConfiguration: UIContentConfiguration, Hashable, Equatable {
    let state: BlockLinkState
    private(set) var currentConfigurationState: UICellConfigurationState?
    
    func makeContentView() -> UIView & UIContentView {
        return BlockLinkView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfig = self

        updatedConfig.currentConfigurationState = state

        return updatedConfig
    }
}
