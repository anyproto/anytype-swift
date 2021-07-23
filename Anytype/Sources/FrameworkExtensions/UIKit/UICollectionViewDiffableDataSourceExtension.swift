import UIKit


extension UICollectionViewDiffableDataSource {
    /// Reapplies the current snapshot to the data source.
    /// - Parameters:
    ///   - completion: A closure to be called on completion of reapplying the snapshot.
    ///   - animatingDifferences: Animate refresh (animating the differences).
    func refresh(animatingDifferences: Bool, completion: (() -> Void)? = nil) {
        self.apply(self.snapshot(), animatingDifferences: animatingDifferences, completion: completion)
    }
}
