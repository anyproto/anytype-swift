import UIKit

class DynamicCollectionView: UICollectionView {
    var onChangeHandler: (() -> Void)?

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)

        isScrollEnabled = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        isScrollEnabled = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !__CGSizeEqualToSize(bounds.size, intrinsicContentSize) {
            invalidateIntrinsicContentSize()
            onChangeHandler?()
        }
    }

    override func reloadData() {
        super.reloadData()

        collectionViewLayout.invalidateLayout()
        collectionViewLayout.prepare()
    }

    override var intrinsicContentSize: CGSize { collectionViewLayout.collectionViewContentSize }
}
