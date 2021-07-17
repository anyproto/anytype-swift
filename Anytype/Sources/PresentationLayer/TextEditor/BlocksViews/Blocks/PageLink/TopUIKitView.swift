
import UIKit

final class TopUIKitView: UIView {

    // MARK: Views
    // |    contentView    | : | leftView | textView |

    var contentView: UIView!
    var leftView: UIView!
    var textView: UIView!

    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    // MARK: Setup
    func setup() {
        self.setupUIElements()
        self.addLayout()
    }

    // MARK: UI Elements
    func setupUIElements() {
        self.translatesAutoresizingMaskIntoConstraints = false

        self.leftView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        self.textView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        self.contentView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        self.contentView.addSubview(leftView)
        self.contentView.addSubview(textView)

        self.addSubview(contentView)
    }

    // MARK: Layout
    func addLayout() {
        if let view = self.leftView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
        if let view = self.textView, let superview = view.superview, let leftView = self.leftView {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: leftView.trailingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
        if let view = self.contentView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
    }

    // MARK: Update / (Could be placed in `layoutSubviews()`)
    func updateView() {
        // toggle animation also
    }

    func updateIfNeeded(leftViewSubview: UIView?, _ setConstraints: Bool = true) {
        guard let leftViewSubview = leftViewSubview else { return }
        for view in self.leftView.subviews {
            view.removeFromSuperview()
        }
        self.leftView.addSubview(leftViewSubview)
        let view = leftViewSubview
        if setConstraints, let superview = view.superview {
            view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
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

    // MARK: Configured
    func configured(textView: UIView?) -> Self {
        self.updateIfNeeded(rightView: textView)
        return self
    }

    func configured(rightView: UIView?) -> Self {
        self.updateIfNeeded(rightView: rightView)
        return self
    }
}
