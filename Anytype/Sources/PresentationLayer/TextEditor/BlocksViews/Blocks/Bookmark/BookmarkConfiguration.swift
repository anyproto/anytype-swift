import UIKit
import BlocksModels

enum BlockBookmarkContentState: Hashable, Equatable {
    case onlyURL(String)
    case fetched(BlockBookmarkPayload)
}

struct BlockBookmarkConfiguration: UIContentConfiguration, Hashable {
    
    let state: BlockBookmarkContentState
            
    func makeContentView() -> UIView & UIContentView {
        BlockBookmarkContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> BlockBookmarkConfiguration {
        return self
    }
}
