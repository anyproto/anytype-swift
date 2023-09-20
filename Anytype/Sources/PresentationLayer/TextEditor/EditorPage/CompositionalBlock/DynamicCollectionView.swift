import UIKit

final class DynamicCollectionView: EditorCollectionView {
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
        backgroundColor = .Background.primary
        isDirectionalLockEnabled = true
        allowsMultipleSelection = true
        allowsSelectionDuringEditing = true
        isEditing = true
    }

    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        print("ContentOffset: \(contentOffset)")
        super.setContentOffset(contentOffset, animated: animated)
    }
    override func layoutSubviews() {
        super.layoutSubviews()

        if !bounds.size.equalTo(intrinsicContentSize) {
            invalidateIntrinsicContentSize()
            onChangeHandler?()
        }
    }

    override var intrinsicContentSize: CGSize { collectionViewLayout.collectionViewContentSize }
}
