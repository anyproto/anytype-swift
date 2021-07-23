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
    
    func makeContentView() -> UIView & UIContentView {
        BlocksFileEmptyView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        self
    }
}
