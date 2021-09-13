import UIKit

final class TextBlockSelectionView: UIView {
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
