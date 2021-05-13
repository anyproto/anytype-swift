import UIKit

class PageTitleUIKitView: UIView {
    // MARK: Views
    // |    topView    | : | leftView | textView |
    // |   leftView    | : |  button  |

    var contentView: UIView!
    var topView: TopWithChildUIKitView!

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
            let view = TopWithChildUIKitView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        _ = self.topView.configured(leftChild: UIView.empty())

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

    // MARK: Configured
    func configured(textView: BlockTextView?) -> Self {
        if let attributes = textView?.textView?.typingAttributes {
            var correctedAttributes = attributes
            correctedAttributes[.font] = UIFont.titleFont
            textView?.textView?.typingAttributes = correctedAttributes
        }
        _ = self.topView.configured(textView: textView)
        return self
    }
}
