import UIKit

class DismissableInputAccessoryView: UIView {

    private enum Constants {
        static let separatorHeight: CGFloat = 0.5
    }
    
    var dismissHandler: (() -> Void)?
    private(set) weak var topSeparator: UIView?
    private var transparentView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
    }
    
    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        guard let window = window else {
            topSeparator?.removeFromSuperview()
            topSeparator = nil
            return
        }
        transparentView?.removeFromSuperview()
        topSeparator?.removeFromSuperview()
        addTransparentViewForDismissAction(parentView: window)
        addTopSeparator()
    }
    
    func didShow(from textView: UITextView) {}
    
    private func addTopSeparator() {
        let topSeparator = UIView()
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        topSeparator.backgroundColor = .systemGray4
        addSubview(topSeparator)
        NSLayoutConstraint.activate([
            topSeparator.topAnchor.constraint(equalTo: topAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: Constants.separatorHeight),
            topSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        self.topSeparator = topSeparator
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
        removeFromSuperview()
        dismissHandler?()
    }
}
