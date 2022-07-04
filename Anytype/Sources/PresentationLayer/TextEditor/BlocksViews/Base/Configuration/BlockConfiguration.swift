import UIKit

protocol BlockConfiguration: Hashable, Dequebale where View.Configuration == Self {
    associatedtype View: BlockContentView

    var hasOwnBackground: Bool { get }

    var isAnimationEnabled: Bool { get }
    var contentInsets: UIEdgeInsets { get }
}

extension BlockConfiguration {
    var hasOwnBackground: Bool { false }

    var contentInsets: UIEdgeInsets { .init(top: 2, left: 20, bottom: -2, right: -20) }

    var isAnimationEnabled: Bool { true }
}

struct BlockDragConfiguration {
    let id: String
}

extension BlockConfiguration {
    func cellBlockConfiguration(
        indentationSettings: IndentationSettings?,
        dragConfiguration: BlockDragConfiguration?
    ) -> CellBlockConfiguration<Self> {
        CellBlockConfiguration(
            blockConfiguration: self,
            currentConfigurationState: nil,
            indentationSettings: indentationSettings,
            dragConfiguration: dragConfiguration
        )
    }

    func spreadsheetConfiguration(
        dragConfiguration: BlockDragConfiguration?,
        styleConfiguration: SpreadsheetStyleConfiguration
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
    func dequeueReusableCell(
        collectionView: UICollectionView,
        for indexPath: IndexPath
    ) -> UICollectionViewCell
}

extension Dequebale where Self: BlockConfiguration {
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
