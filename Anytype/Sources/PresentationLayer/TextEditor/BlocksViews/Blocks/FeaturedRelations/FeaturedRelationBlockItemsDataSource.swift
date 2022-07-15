import UIKit

final class FeaturedRelationBlockItemsDataSource: NSObject, UICollectionViewDataSource {
    var items = [Dequebale]() {
        didSet {
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.collectionViewLayout.prepare()
        }
    }

    private let collectionView: UICollectionView

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView

        super.init()

        collectionView.dataSource = self

        collectionView.register(
            GenericCollectionViewCell<RelationValueViewUIKit>.self,
            forCellWithReuseIdentifier: RelationValueViewUIKit.reusableIdentifier
        )

        collectionView.register(
            GenericCollectionViewCell<SeparatorItemView>.self,
            forCellWithReuseIdentifier: SeparatorItemView.reusableIdentifier
        )
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]

        return item.dequeueReusableCell(
            collectionView: collectionView,
            for: indexPath
        )
    }
}
