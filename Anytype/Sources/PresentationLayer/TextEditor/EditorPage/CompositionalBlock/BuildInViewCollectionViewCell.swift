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

//    override func systemLayoutSizeFitting(
//        _ targetSize: CGSize,
//        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
//        verticalFittingPriority: UILayoutPriority) -> CGSize {
//
//            // Replace the height in the target size to
//            // allow the cell to flexibly compute its height
//            var targetSize = targetSize
//            targetSize.height = CGFloat.greatestFiniteMagnitude
//
//            // The .required horizontal fitting priority means
//            // the desired cell width (targetSize.width) will be
//            // preserved. However, the vertical fitting priority is
//            // .fittingSizeLevel meaning the cell will find the
//            // height that best fits the content
//            let size = super.systemLayoutSizeFitting(
//                targetSize,
//                withHorizontalFittingPriority: .required,
//                verticalFittingPriority: .fittingSizeLevel
//            )
//
//            return size
//        }
}
