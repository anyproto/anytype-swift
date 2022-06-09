import UIKit

private enum Constants {
    static let edges = UIEdgeInsets(top: 9, left: 12, bottom: -9, right: -12)
}

final class SimpleTableCollectionViewCell<View: BlockContentView>: UICollectionViewCell {
    private let containerView = View(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    func update(with configuration: View.Configuration) {
        containerView.update(with: configuration)
    }

    private func setup() {
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.strokePrimary.cgColor

        addSubview(containerView) {
            $0.pinToSuperview(excluding: [.bottom], insets: Constants.edges)
            $0.bottom.greaterThanOrEqual(
                to: bottomAnchor,
                constant: Constants.edges.bottom,
                priority: .init(999)
            )
        }
    }
}
