

import Combine
import UIKit

final class TopWithChildUIKitView: UIView {
    struct Resource {
        var textColor: UIColor?
        var backgroundColor: UIColor?
    }

    private var resourceSubscription: AnyCancellable?

    // TODO: Refactor
    // OR
    // We could do it on toggle level or on block parsing level?
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
        if let view = self.topView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
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

    func updateIfNeeded(leftChild: UIView?, setConstraints: Bool = false) {
        guard let leftChild = leftChild else { return }
        self.topView.updateIfNeeded(leftViewSubview: leftChild, setConstraints)
        leftChild.translatesAutoresizingMaskIntoConstraints = false
        self.leftView = leftChild
        self.onLeftChildWillLayout(leftChild)
    }

    // MARK: Configured
    func configured(leftChild: UIView?, setConstraints: Bool = false) -> Self {
        self.updateIfNeeded(leftChild: leftChild, setConstraints: setConstraints)
        return self
    }

    func configured(textView: BlockTextView?) -> Self {
        _ = self.topView.configured(textView: textView)
        return self
    }

    func configured(rightView: UIView?) -> Self {
        _ = self.topView.configured(rightView: rightView)
        return self
    }

    func configured(_ resourceStream: AnyPublisher<Resource, Never>) -> Self {
        self.resourceSubscription = resourceStream.reciveOnMain().sink { [weak self] (value) in
            self?.backgroundColor = value.backgroundColor
        }
        return self
    }
}
