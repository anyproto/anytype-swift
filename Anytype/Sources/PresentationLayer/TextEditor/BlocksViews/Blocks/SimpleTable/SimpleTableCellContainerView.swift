import UIKit

// Would be rewrited to same generic behaviour to use reusable feature properly
class SimpleTableCellContainerView: UIView, BlockContentView {
    private enum Constants {
        static let edges = UIEdgeInsets(top: 9, left: 12, bottom: -9, right: -12)
    }

    var innerView: UIView? {
        didSet {
            removeAllSubviews()

            if let innerView = innerView {
                addSubview(innerView) {
                    $0.pinToSuperview(excluding: [.bottom], insets: Constants.edges)
                    $0.bottom.greaterThanOrEqual(
                        to: bottomAnchor,
                        constant: Constants.edges.bottom,
                        priority: .init(999)
                    )
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    func update(with configuration: SimpleTableCellConfiguration) {
        self.innerView = configuration.view

        backgroundColor = configuration.backgroundColor
    }

    private func setup() {
        backgroundColor = .green
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.strokePrimary.cgColor
    }
}
