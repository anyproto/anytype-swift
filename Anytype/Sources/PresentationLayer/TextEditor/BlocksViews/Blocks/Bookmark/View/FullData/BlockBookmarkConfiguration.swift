import UIKit
import BlocksModels

struct BlockBookmarkConfiguration: BlockConfigurationProtocol, Hashable {
    
    let payload: BlockBookmarkPayload
    var currentConfigurationState: UICellConfigurationState?
            
    func makeContentView() -> UIView & UIContentView {
        BlockBookmarkView(configuration: self)
    }
}
