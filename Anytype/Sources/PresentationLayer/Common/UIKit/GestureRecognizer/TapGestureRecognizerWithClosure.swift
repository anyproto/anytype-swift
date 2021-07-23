import UIKit

final class TapGestureRecognizerWithClosure: UITapGestureRecognizer {
    
    // MARK: - Private variables
    
    private let action: () -> Void

    // MARK: - Initializer
    
    init(_ action: @escaping () -> Void) {
        self.action = action
        
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }

    // MARK: - Private func
    
    @objc private func execute() {
        action()
    }
    
}
