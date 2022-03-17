import UIKit

struct ObjectHeaderEmptyConfiguration: UIContentConfiguration, Hashable {
    let data: ObjectHeaderEmptyData
    
    func makeContentView() -> UIView & UIContentView {
        ObjectHeaderEmptyContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}
