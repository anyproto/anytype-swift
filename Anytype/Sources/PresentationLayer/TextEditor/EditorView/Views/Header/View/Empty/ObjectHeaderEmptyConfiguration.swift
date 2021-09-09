import UIKit

struct ObjectHeaderEmptyConfiguration: UIContentConfiguration, Hashable {
    
    func makeContentView() -> UIView & UIContentView {
       ObjectHeaderEmptyContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        self
    }
    
}
