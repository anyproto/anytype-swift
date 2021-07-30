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

    func updateIfNeeded(leftViewSubview: UIView) {
        leftView.removeAllSubviews()
        leftView.addSubview(leftViewSubview) {
            $0.pinToSuperview()
        }
    }

    func updateIfNeeded(rightView: UIView) {
        textView.removeAllSubviews()
        textView.addSubview(rightView) {
            $0.pinToSuperview()
        }
    }

}
