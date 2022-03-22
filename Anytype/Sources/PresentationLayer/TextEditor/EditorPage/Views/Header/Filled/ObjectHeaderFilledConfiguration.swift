import UIKit

struct ObjectHeaderFilledConfiguration: UIContentConfiguration, Hashable {
        
    let state: ObjectHeaderFilledState
    let width: CGFloat
    var topAdjustedContentInset: CGFloat = 0
    private(set) var isLocked = false
    
    func makeContentView() -> UIView & UIContentView {
        ObjectHeaderFilledContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        var currentState = self
        (state as? UICellConfigurationState).map { currentState.isLocked = $0.isLocked }

        return currentState
    }
}
