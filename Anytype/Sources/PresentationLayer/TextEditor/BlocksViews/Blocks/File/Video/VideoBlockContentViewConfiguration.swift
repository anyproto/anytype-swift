import BlocksModels
import UIKit

struct VideoBlockConfiguration: Hashable {
    
    let file: BlockFile
    private(set) var currentConfigurationState: UICellConfigurationState?
    
    init(fileData: BlockFile) {
        self.file = fileData
    }
}

extension VideoBlockConfiguration: UIContentConfiguration {
    
    func makeContentView() -> UIView & UIContentView {
        return VideoBlockContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfig = self

        updatedConfig.currentConfigurationState = state

        return updatedConfig
    }
}
