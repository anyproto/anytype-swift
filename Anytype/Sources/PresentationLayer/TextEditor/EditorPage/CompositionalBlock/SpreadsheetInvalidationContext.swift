import UIKit

final class SpreadsheetInvalidationContext: UICollectionViewLayoutInvalidationContext {
    override var invalidateEverything: Bool { false }

    override var invalidateDataSourceCounts: Bool { true }
}
