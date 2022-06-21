import UIKit

final class EditorViewListCell: UICollectionViewListCell, CustomTypesAccessable {
    override func prepareForReuse() {
        super.prepareForReuse()

        print("I AM \(reuseIdentifier) with content view like \(contentConfiguration)")
    }

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
}
