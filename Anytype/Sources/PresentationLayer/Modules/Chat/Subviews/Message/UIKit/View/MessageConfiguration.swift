import UIKit

struct MessageConfiguration: UIContentConfiguration {
    
    let model: MessageViewData
    let layout: MessageLayout
    
    func makeContentView() -> any UIView & UIContentView {
        MessageUIView(configuration: self)
    }
    
    func updated(for state: any UIConfigurationState) -> Self {
        return self
    }
}
