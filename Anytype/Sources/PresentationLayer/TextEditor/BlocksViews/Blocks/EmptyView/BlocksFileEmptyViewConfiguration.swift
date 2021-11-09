import UIKit

enum BlocksFileEmptyViewState {
    case `default`
    case uploading
    case error
}

struct BlocksFileEmptyViewConfiguration: UIContentConfiguration {
    let image: UIImage
    let text: String
    let state: BlocksFileEmptyViewState
    private(set) var currentConfigurationState: UICellConfigurationState?
    
    func makeContentView() -> UIView & UIContentView {
        BlocksFileEmptyView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfig = self

        updatedConfig.currentConfigurationState = state

        return updatedConfig
    }
}
