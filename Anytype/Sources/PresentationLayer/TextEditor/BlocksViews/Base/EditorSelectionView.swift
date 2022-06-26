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
        if isSelected {
            layer.borderWidth = Constants.borderWidth
            layer.borderColor = UIColor.System.amber.cgColor
            backgroundColor = UIColor.System.amber.withAlphaComponent(0.2)
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
            layer.borderColor = UIColor.System.amber.cgColor
        } else {
            layer.borderWidth = 0.0
            backgroundColor = .clear
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
