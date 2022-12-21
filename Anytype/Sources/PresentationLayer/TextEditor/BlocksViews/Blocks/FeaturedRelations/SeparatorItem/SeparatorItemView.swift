import UIKit

final class SeparatorItemView: UIView, BlockContentView {
    private let label = UILabel(frame: .zero)
    private var heightConstraint: NSLayoutConstraint?

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
    private func setup() {
        label.textColor = .TextNew.secondary
        label.font = .systemFont(ofSize: 13)

        heightConstraint = label.heightAnchor.constraint(equalToConstant: 18)
        heightConstraint?.priority = .defaultLow
        heightConstraint?.isActive = true

        addSubview(label) {
            $0.pinToSuperview()
        }

        label.translatesAutoresizingMaskIntoConstraints = false
    }

    func update(with configuration: SeparatorItemConfiguration) {
        label.text = configuration.style.string
    }
}

struct SeparatorItemConfiguration: BlockConfiguration {
    typealias View = SeparatorItemView
    enum Style: Hashable {
        case dot

        var string: String {
            switch self {
            case .dot: return "•"
            }
        }
    }

    let style: Style
    let height: CGFloat
}
