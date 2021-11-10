import UIKit
import BlocksModels

struct BlockLinkContentConfiguration: AnytypeBlockContentConfigurationProtocol, Hashable, Equatable {
    let state: BlockLinkState
    var currentConfigurationState: UICellConfigurationState?
    
    func makeContentView() -> UIView & UIContentView {
        return BlockLinkView(configuration: self)
    }
}
