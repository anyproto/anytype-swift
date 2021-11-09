import UIKit
import BlocksModels

struct BlockFileConfiguration: UIContentConfiguration, Hashable {
    let data: BlockFileMediaData
    private(set) var currentConfigurationState: UICellConfigurationState?

    init(_ fileData: BlockFileMediaData) {
        self.data = fileData
    }
            
    func makeContentView() -> UIView & UIContentView {
        return BlockFileView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfig = self

        updatedConfig.currentConfigurationState = state

        return updatedConfig
    }
}
