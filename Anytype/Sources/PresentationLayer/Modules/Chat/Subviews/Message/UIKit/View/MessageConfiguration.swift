import UIKit

struct MessageConfiguration: UIContentConfiguration {
    
    let model: MessageViewData
    
    func makeContentView() -> any UIView & UIContentView {
        MessageUIView(configuration: self)
    }
    
    func updated(for state: any UIConfigurationState) -> Self {
        return self
    }
}
