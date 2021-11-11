import UIKit
import BlocksModels

struct BlockFileConfiguration: AnytypeBlockContentConfigurationProtocol, Hashable {
    let data: BlockFileMediaData
    var currentConfigurationState: UICellConfigurationState?

    init(_ fileData: BlockFileMediaData) {
        self.data = fileData
    }
            
    func makeContentView() -> UIView & UIContentView {
        return BlockFileView(configuration: self)
    }
}
