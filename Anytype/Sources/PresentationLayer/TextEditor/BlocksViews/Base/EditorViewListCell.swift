import UIKit

final class EditorViewListCell: UICollectionViewListCell, CustomTypesAccessable {
    var isMoving: Bool = false {
        didSet {
            // Ensure that an update is performed whenever this property changes.
            if oldValue != isMoving {
                setNeedsUpdateConfiguration()
            }
        }
    }

    var isLocked: Bool = false {
        didSet {
            // Ensure that an update is performed whenever this property changes.
            if oldValue != isLocked {
                setNeedsUpdateConfiguration()
            }
        }
    }

    override var configurationState: UICellConfigurationState {
        var state = super.configurationState

        state.isMoving = isMoving
        state.isLocked = isLocked

        return state
    }

        override func systemLayoutSizeFitting(
            _ targetSize: CGSize,
            withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
            verticalFittingPriority: UILayoutPriority) -> CGSize {

                // Replace the height in the target size to
                // allow the cell to flexibly compute its height
                var targetSize = targetSize
                targetSize.height = CGFloat.greatestFiniteMagnitude

                // The .required horizontal fitting priority means
                // the desired cell width (targetSize.width) will be
                // preserved. However, the vertical fitting priority is
                // .fittingSizeLevel meaning the cell will find the
                // height that best fits the content
                let size = super.systemLayoutSizeFitting(
                    targetSize,
                    withHorizontalFittingPriority: .required,
                    verticalFittingPriority: .fittingSizeLevel
                )

                return size
            }
}
