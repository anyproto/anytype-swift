import UIKit
import BlocksModels

struct BlockBookmarkOnlyUrlConfiguration: UIContentConfiguration, Hashable {
    
    let ulr: String
            
    func makeContentView() -> UIView & UIContentView {
        BlockBookmarkOnlyUrlView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> BlockBookmarkOnlyUrlConfiguration {
        return self
    }
}
