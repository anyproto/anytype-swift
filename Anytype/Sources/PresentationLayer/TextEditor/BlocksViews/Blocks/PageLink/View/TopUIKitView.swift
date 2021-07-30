import UIKit

final class TopUIKitView: UIView {
    let leftView = UIView()
    let textView = UIView()
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    // MARK: Setup
    func setup() {
        addSubview(leftView) {
            $0.pinToSuperview(excluding: [.right])
        }
        addSubview(textView) {
            $0.pinToSuperview(excluding: [.left])
            $0.leading.equal(to: leftView.trailingAnchor)
        }
    }

    func updateIfNeeded(leftViewSubview: UIView?) {
        guard let leftViewSubview = leftViewSubview else { return }
        leftView.removeAllSubviews()
        leftView.addSubview(leftViewSubview)
    }

    func updateIfNeeded(rightView: UIView?) {
        guard let textView = rightView else { return }
        for view in self.textView.subviews {
            view.removeFromSuperview()
        }
        self.textView.addSubview(textView)
        let view = textView
        if let superview = view.superview {
            view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
    }

}
