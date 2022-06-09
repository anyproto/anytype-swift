import UIKit

protocol SimpleTableBlockProtocol: Dequebale, HashableProvier {}

struct SimpleTableCellConfiguration<Configuration: BlockConfiguration>: SimpleTableBlockProtocol {
    let item: Configuration
    let backgroundColor: UIColor?

    var hashable: AnyHashable { item.hashValue as AnyHashable }

    init(
        item: Configuration,
        backgroundColor: UIColor?
    ) {
        self.item = item
        self.backgroundColor = backgroundColor
    }
}

extension SimpleTableCellConfiguration: ReusableContent {
    static var reusableIdentifier: String {
        Configuration.View.reusableIdentifier
    }
}

extension SimpleTableCellConfiguration {
    func dequeueReusableCell(
        collectionView: UICollectionView,
        for indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Self.reusableIdentifier,
            for: indexPath
        ) as? SimpleTableCollectionViewCell<Configuration.View>

        cell?.update(with: item)

        return cell ?? UICollectionViewCell()
    }
}
