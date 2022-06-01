import UIKit

final class DynamicCollectionView: UICollectionView {
    var onChangeHandler: (() -> Void)?

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }

    private func setup() {
        isScrollEnabled = true
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

//        backgroundColor = .red
        collectionViewLayout.invalidateLayout()
        collectionViewLayout.prepare()
    }

    override var intrinsicContentSize: CGSize { collectionViewLayout.collectionViewContentSize }
}
