import UIKit

final class DynamicCollectionView: UICollectionView {
    var onChangeHandler: (() -> Void)?

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)

//        isScrollEnabled = false
        isDirectionalLockEnabled = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
//        isScrollEnabled = false
        isDirectionalLockEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !bounds.size.equalTo(intrinsicContentSize) {
            invalidateIntrinsicContentSize()
            onChangeHandler?()
        }
    }

    override func reloadData() {
        super.reloadData()

        backgroundColor = .red
        collectionViewLayout.invalidateLayout()
        collectionViewLayout.prepare()
    }

    override var intrinsicContentSize: CGSize { collectionViewLayout.collectionViewContentSize }
}
