import UIKit

protocol BlockConfiguration: Hashable, Dequebale where View.Configuration == Self {
    associatedtype View: BlockContentView

    var hasOwnBackground: Bool { get }

    var isAnimationEnabled: Bool { get }
    
    var contentInsets: UIEdgeInsets { get }
    var selectionInsets: UIEdgeInsets { get }
    var spreadsheetInsets: UIEdgeInsets { get }
}

extension BlockConfiguration {
    var hasOwnBackground: Bool { false }

    var contentInsets: UIEdgeInsets { UIEdgeInsets(top: 2, left: 20, bottom: 2, right: 20) }
    var selectionInsets: UIEdgeInsets { UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8) }
    var spreadsheetInsets: UIEdgeInsets { UIEdgeInsets(top: 9, left: 12, bottom: 9, right: 12) }

    var isAnimationEnabled: Bool { true }
}

struct BlockDragConfiguration {
    let id: String
}

extension BlockConfiguration {
    func cellBlockConfiguration(
        dragConfiguration: BlockDragConfiguration?,
        styleConfiguration: CellStyleConfiguration?
    ) -> CellBlockConfiguration<Self> {
        CellBlockConfiguration(
            blockConfiguration: self,
            currentConfigurationState: nil,
            dragConfiguration: dragConfiguration,
            styleConfiguration: styleConfiguration
        )
    }

    func spreadsheetConfiguration(
        dragConfiguration: BlockDragConfiguration?,
        styleConfiguration: CellStyleConfiguration
    ) -> SpreadsheetBlockConfiguration<Self> {
        SpreadsheetBlockConfiguration(
            blockConfiguration: self,
            styleConfiguration: styleConfiguration,
            currentConfigurationState: nil,
            dragConfiguration: dragConfiguration
        )
    }
}

protocol Dequebale {
    @MainActor
    func dequeueReusableCell(
        collectionView: UICollectionView,
        for indexPath: IndexPath
    ) -> UICollectionViewCell
}

extension Dequebale where Self: BlockConfiguration {
    @MainActor
    func dequeueReusableCell(
        collectionView: UICollectionView,
        for indexPath: IndexPath
    ) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Self.View.reusableIdentifier,
            for: indexPath
        ) as? GenericCollectionViewCell<Self.View>
        collectionViewCell?.update(with: self)

        return collectionViewCell ?? UICollectionViewCell()
    }
}
