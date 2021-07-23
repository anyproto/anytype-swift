import UIKit

struct BlocksFileEmptyViewConfiguration: UIContentConfiguration {
    let image: UIImage
    let text: String
    
    func makeContentView() -> UIView & UIContentView {
        BlocksFileEmptyView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        self
    }
}
