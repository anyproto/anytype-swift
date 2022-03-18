import UIKit

struct ObjectHeaderEmptyConfiguration: UIContentConfiguration, Hashable {
    let data: ObjectHeaderEmptyData
    var isLocked = false
    
    func makeContentView() -> UIView & UIContentView {
        ObjectHeaderEmptyContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        var currentState = self
        (state as? UICellConfigurationState).map { currentState.isLocked = $0.isLocked }
        
        return currentState
    }
}
