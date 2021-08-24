import UIKit

struct ObjectHeaderEmptyConfiguration: UIContentConfiguration, Hashable {
//    let data: ObjectHeader
    
    func makeContentView() -> UIView & UIContentView {
       ObjectHeaderEmptyContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        self
    }
    
}
