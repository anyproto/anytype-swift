import UIKit

final class EditorSelectionView: UIView {
    enum Constants {
        static let borderWidth = 1.5
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 6
        layer.cornerCurve = .continuous
        isUserInteractionEnabled = false
        clipsToBounds = true
    }

    func updateStyle(isSelected: Bool) {
        UIView.animate(withDuration: 0.34, delay: 0) { [weak self] in
            guard let self else { return }
            if isSelected {
                layer.borderWidth = Constants.borderWidth
                dynamicBorderColor = UIColor.Control.accent100
                backgroundColor = UIColor.Control.accent100.withAlphaComponent(0.2)
            } else {
                layer.borderWidth = 0.0
                dynamicBorderColor = nil
                backgroundColor = .clear
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


final class SpreadsheetSelectionView: UIView {
    enum Constants {
        static let borderWidth: CGFloat = 2
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 2
        layer.cornerCurve = .continuous
        isUserInteractionEnabled = false
        clipsToBounds = true
    }

    func updateStyle(isSelected: Bool) {
        if isSelected {
            layer.borderWidth = Constants.borderWidth
            dynamicBorderColor = UIColor.Control.accent100
        } else {
            layer.borderWidth = 0.0
            backgroundColor = .clear
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
