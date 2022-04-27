import UIKit
import BlocksModels

// Used only for iOS14.
private class iOS14CompositionalContentHeightStorage {
    static let shared = iOS14CompositionalContentHeightStorage()

    var blockHeightConstant = [AnyHashable: CGFloat]()
}

struct DynamicCompositionalLayoutConfiguration: Hashable {
    var hashable: AnyHashable

    @EquatableNoop var compositionalLayout: UICollectionViewCompositionalLayout
    @EquatableNoop var views: [UIView]
    @EquatableNoop var heightDidChanged: () -> Void
}

final class DynamicCompositionalLayoutView: UIView, UICollectionViewDataSource {

    private(set) lazy var collectionView: DynamicCollectionView = {
        let collectionView = DynamicCollectionView(
            frame: .init(
                origin: .zero,
                size: .init(width: 370, height: 70) // just non-nil size
            ),
            collectionViewLayout: UICollectionViewFlowLayout() // temporary layout
        )

        return collectionView
    }()

    private var collectionViewHeightConstraint: NSLayoutConstraint?
    private var configuration: DynamicCompositionalLayoutConfiguration?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        collectionView.isUserInteractionEnabled = false
        addSubview(collectionView) {
            $0.pinToSuperview(excluding: [.bottom])
            collectionViewHeightConstraint = $0.height.equal(to: 60, priority: .init(rawValue: 999))
            $0.bottom.greaterThanOrEqual(to: bottomAnchor, priority: .defaultLow)
        }

        collectionView.register(
            BuildInViewCollectionViewCell.self,
            forCellWithReuseIdentifier: String(describing: BuildInViewCollectionViewCell.self)
        )

        collectionView.dataSource = self

        setupSizeHandlers()
    }

    private func setupSizeHandlers() {
        collectionView.onChangeHandler = { [weak self] in
            guard let self = self else { return }
            guard self.collectionViewHeightConstraint?.constant ?? -1 != self.collectionView.intrinsicContentSize.height else { return }

            self.collectionViewHeightConstraint?.constant = self.collectionView.intrinsicContentSize.height

            self.configuration.map {
                iOS14CompositionalContentHeightStorage.shared.blockHeightConstant[$0.hashable] = self.collectionView.intrinsicContentSize.height
            }

            if #available(iOS 15.0, *) { } else {
                self.configuration?.heightDidChanged()
            }
        }
    }

    func update(with configuration: DynamicCompositionalLayoutConfiguration) {
        self.configuration = configuration

        collectionView.collectionViewLayout = configuration.compositionalLayout

        collectionView.reloadData()

        if let height = iOS14CompositionalContentHeightStorage.shared.blockHeightConstant[configuration.hashable] {
            collectionViewHeightConstraint?.constant = height
        } else {
            collectionViewHeightConstraint?.constant = collectionView.intrinsicContentSize.height
        }

        collectionViewHeightConstraint?.isActive = true
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        configuration?.views.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: BuildInViewCollectionViewCell.self),
            for: indexPath
        ) as? BuildInViewCollectionViewCell


        cell?.innerView = configuration?.views[indexPath.row]
        return cell ?? UICollectionViewCell()
    }
}
