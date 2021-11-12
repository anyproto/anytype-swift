import UIKit
import BlocksModels

struct BlockLinkContentConfiguration: BlockConfigurationProtocol, Hashable, Equatable {
    let state: BlockLinkState
    var currentConfigurationState: UICellConfigurationState?
    
    func makeContentView() -> UIView & UIContentView {
        BlockLinkView(configuration: self)
    }
}
