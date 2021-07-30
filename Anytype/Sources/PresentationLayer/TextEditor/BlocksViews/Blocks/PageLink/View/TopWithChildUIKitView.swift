
import Combine
import UIKit


final class TopWithChildUIKitView: UIView {
    struct Layout {
        var containedViewInset = 8
        var indentationWidth = 8
        var boundaryWidth = 2
    }

    // MARK: Views
    // |    topView    | : | leftView | textView |
    // |   leftView    | : |  button  |

    var contentView: UIView!
    var topView: TopUIKitView!
    var leftView: UIView!
    var onLeftChildWillLayout: (UIView?) -> () = { view in
        if let view = view, let superview = view.superview {
            var constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor),
            ]
            if view.intrinsicContentSize.width != UIView.noIntrinsicMetric {
                constraints.append(view.widthAnchor.constraint(equalToConstant: view.intrinsicContentSize.width))
            }
            if view.intrinsicContentSize.height != UIView.noIntrinsicMetric {
                constraints.append(view.heightAnchor.constraint(equalToConstant: view.intrinsicContentSize.height))
            }
            NSLayoutConstraint.activate(constraints)
        }
    }

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

        self.contentView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        self.topView = {
            let view = TopUIKitView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        self.leftView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        self.contentView.addSubview(topView)

        self.addSubview(contentView)
    }

    // MARK: Layout
    func addLayout() {
        topView.edgesToSuperview()
        contentView.edgesToSuperview()
    }

    func updateIfNeeded(leftChild: UIView?) {
        guard let leftChild = leftChild else { return }
        topView.updateIfNeeded(leftViewSubview: leftChild)
        leftChild.translatesAutoresizingMaskIntoConstraints = false
        self.leftView = leftChild
        self.onLeftChildWillLayout(leftChild)
    }

    func configured(view: UIView?) {
        topView.updateIfNeeded(rightView: view)
    }
}
