
import UIKit

final class TopUIKitView: UIView {

    // MARK: Views
    // |    contentView    | : | leftView | textView |

    var contentView = UIView()
    var leftView = UIView()
    var textView = UIView()
    
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
        contentView.addSubview(leftView) {
            $0.pinToSuperview(excluding: [.right])
        }
        self.contentView.addSubview(textView) {
            $0.pinToSuperview(excluding: [.left])
            $0.leading.equal(to: leftView.trailingAnchor)
        }

        self.addSubview(contentView) {
            $0.pinToSuperview()
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
