
import UIKit

class DismissableInputAccessoryView: UIView {
    
    let dismissHandler: () -> Void
    private var transparentButton: UIButton?
    
    init(frame: CGRect,
         dismissHandler: @escaping () -> Void) {
        self.dismissHandler = dismissHandler
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
    }
    
    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        guard let window = window else { return }
        self.transparentButton?.removeFromSuperview()
        addTransparentButtonForDismissAction(parentView: window)
    }
    
    private func addTransparentButtonForDismissAction(parentView: UIWindow) {
        let button = UIButton(primaryAction: UIAction(handler: { [weak self] action in
            let button = action.sender as? UIButton
            button?.removeFromSuperview()
            self?.dismissHandler()
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: topAnchor),
            button.topAnchor.constraint(equalTo: parentView.topAnchor)
        ])
        transparentButton = button
    }
}
