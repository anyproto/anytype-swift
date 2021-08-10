import UIKit
import BlocksModels


struct BlockLinkContentConfiguration: UIContentConfiguration, Hashable, Equatable {
    let content: BlockLink
    let state: BlockLinkState
    
    func makeContentView() -> UIView & UIContentView {
        return BlockLinkContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> BlockLinkContentConfiguration {
        return self
    }
}
