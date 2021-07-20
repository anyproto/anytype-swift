import UIKit
import BlocksModels


struct BlockPageLinkContentConfiguration: UIContentConfiguration, Hashable, Equatable {
    let content: BlockLink
    let state: BlockPageLinkState
    
    func makeContentView() -> UIView & UIContentView {
        return BlockPageLinkContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> BlockPageLinkContentConfiguration {
        return self
    }
}
