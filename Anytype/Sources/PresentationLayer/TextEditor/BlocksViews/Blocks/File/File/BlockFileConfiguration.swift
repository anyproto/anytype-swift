import UIKit
import BlocksModels

struct BlockFileConfiguration: UIContentConfiguration, Hashable {
    let data: BlockFileMediaData

    init(_ fileData: BlockFileMediaData) {
        self.data = fileData
    }
            
    func makeContentView() -> UIView & UIContentView {
        return BlockFileView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> BlockFileConfiguration {
        return self
    }
}
