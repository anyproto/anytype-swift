import UIKit
import BlocksModels

struct BlockFileConfiguration: UIContentConfiguration, Hashable {
    let fileData: BlockFile

    init(_ fileData: BlockFile) {
        self.fileData = fileData
    }
            
    func makeContentView() -> UIView & UIContentView {
        return BlockFileContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> BlockFileConfiguration {
        return self
    }
}
