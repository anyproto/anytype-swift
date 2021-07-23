import UIKit
import BlocksModels

struct BlockImageConfiguration: UIContentConfiguration, Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.fileData == rhs.fileData
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fileData)
    }
    
    let fileData: BlockFile

    init(_ fileData: BlockFile) {
        self.fileData = fileData
    }
            
    func makeContentView() -> UIView & UIContentView {
        BlockImageContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> BlockImageConfiguration {
        return self
    }
}
