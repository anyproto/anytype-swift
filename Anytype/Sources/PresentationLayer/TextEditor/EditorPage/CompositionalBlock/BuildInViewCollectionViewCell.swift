import UIKit

class BuildInViewCollectionViewCell: UICollectionViewCell {
    var innerView: UIView? {
        didSet {
            removeAllSubviews()

            if let innerView = innerView {
                addSubview(innerView) {
                    $0.pinToSuperview()
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

    private func setup() {
        
//        layer.borderWidth = 0.5
//        layer.borderColor = UIColor.red.cgColor
    }

//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        var fittingSize = UIView.layoutFittingExpandedSize
//        fittingSize.width = layoutAttributes.size.width
//        let fitSize = systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .required)
//        var fitFrame = layoutAttributes.frame
//        fitFrame.size.height = fitSize.height
//        layoutAttributes.frame = fitFrame
//        return layoutAttributes
//    }
}
