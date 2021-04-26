
import UIKit

class DismissableInputAccessoryView: UIView {
    
    let dismissHandler: () -> Void
    private var transparentView: UIView?
    
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
        transparentView?.removeFromSuperview()
        addTransparentViewForDismissAction(parentView: window)
    }
    
    private func addTransparentViewForDismissAction(parentView: UIWindow) {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                         action: #selector(handleTransparentViewTap)))
        parentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: topAnchor),
            view.topAnchor.constraint(equalTo: parentView.topAnchor)
        ])
        transparentView = view
    }
    
    @objc private func handleTransparentViewTap() {
        dismissHandler()
    }
}
