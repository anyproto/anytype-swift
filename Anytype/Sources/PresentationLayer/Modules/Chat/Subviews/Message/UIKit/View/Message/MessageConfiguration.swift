import UIKit

struct MessageConfiguration: UIContentConfiguration {
    
    let data: MessageUIViewData
    let layout: MessageLayout
    weak var output: (any MessageModuleOutput)?
    
    func makeContentView() -> any UIView & UIContentView {
        MessageUIView(configuration: self)
    }
    
    func updated(for state: any UIConfigurationState) -> Self {
        return self
    }
}
