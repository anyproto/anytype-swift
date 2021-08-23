import UIKit
import BlocksModels

struct BlockBookmarkConfiguration: UIContentConfiguration, Hashable {
    
    let payload: BlockBookmarkPayload
            
    func makeContentView() -> UIView & UIContentView {
        BlockBookmarkContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> BlockBookmarkConfiguration {
        return self
    }
}
