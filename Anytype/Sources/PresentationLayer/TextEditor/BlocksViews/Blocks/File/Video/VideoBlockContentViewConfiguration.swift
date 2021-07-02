import BlocksModels
import UIKit

struct VideoBlockConfiguration: Hashable {
    
    let file: BlockFile
    
    init(fileData: BlockFile) {
        self.file = fileData
    }
}

extension VideoBlockConfiguration: UIContentConfiguration {
    
    func makeContentView() -> UIView & UIContentView {
        return VideoBlockContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> VideoBlockConfiguration {
        self
    }
}
