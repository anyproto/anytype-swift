import UIKit

class BaseBlockView: UIView {
    private static let selectionViewInset: UIEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: -8)

    private let selectionView = BaseSelectionView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupSubviews()
    }

    func update(with state: UICellConfigurationState) {
        selectionView.updateStyle(isSelected: state.isSelected)
    }
    

    private func setupSubviews() {
        addSubview(selectionView) {
            $0.pinToSuperview(insets: BaseBlockView.selectionViewInset)
        }
    }
}

private final class BaseSelectionView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 6
        layer.cornerCurve = .continuous
        isUserInteractionEnabled = false
        clipsToBounds = true
    }

    func updateStyle(isSelected: Bool) {
        if isSelected {
            layer.borderWidth = 2.0
            layer.borderColor = UIColor.pureAmber.cgColor
            backgroundColor = UIColor.pureAmber.withAlphaComponent(0.1)
        } else {
            layer.borderWidth = 0.0
            layer.borderColor = nil
            backgroundColor = .clear
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
