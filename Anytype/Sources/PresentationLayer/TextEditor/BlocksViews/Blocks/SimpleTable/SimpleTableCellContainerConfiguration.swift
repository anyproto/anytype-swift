import UIKit
import Combine

protocol SimpleTableBlockProtocol: Dequebale, HashableProvier {
    var heightDidChangedSubject: PassthroughSubject<Void, Never> { get }
}

struct SimpleTableCellConfiguration<Configuration: BlockConfiguration>: Hashable, SimpleTableBlockProtocol {
    let item: Configuration
    let backgroundColor: UIColor?

    @EquatableNoop var heightDidChangedSubject = PassthroughSubject<Void, Never>()

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
        cell?.backgroundColor = backgroundColor

        if let dynamicHeightView = cell?.containerView as? DynamicHeightView {
            dynamicHeightView.heightDidChanged = {
                heightDidChangedSubject.send()
            }
        }

        return cell ?? UICollectionViewCell()
    }
}
