import UIKit
import BlocksModels


struct BlockLinkContentConfiguration: UIContentConfiguration, Hashable, Equatable {
    let state: BlockLinkState
    
    func makeContentView() -> UIView & UIContentView {
        return BlockLinkView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> BlockLinkContentConfiguration {
        return self
    }
}
