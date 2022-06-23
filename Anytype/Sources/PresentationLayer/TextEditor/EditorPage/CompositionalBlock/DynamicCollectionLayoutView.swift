import UIKit
import BlocksModels

// Used only for iOS14.
private final class iOS14CompositionalContentHeightStorage {
    static let shared = iOS14CompositionalContentHeightStorage()

    var blockHeightConstant = [AnyHashable: CGFloat]()
}

struct DynamicLayoutConfiguration: Hashable {
    let hashable: AnyHashable

    @EquatableNoop var layout: UICollectionViewLayout
    @EquatableNoop var heightDidChanged: () -> Void
}

final class DynamicCollectionLayoutView: UIView {

    private(set) lazy var collectionView: DynamicCollectionView = {
        let collectionView = DynamicCollectionView(
            frame: .init(
                origin: .zero,
                size: .init(width: 370, height: 70) // just non-zero size
            ),
            collectionViewLayout: UICollectionViewFlowLayout() // temporary layout, it will be configured at the time of configuration update
        )

        return collectionView
    }()

    private var collectionViewHeightConstraint: NSLayoutConstraint?
    private var configuration: DynamicLayoutConfiguration?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        addSubview(collectionView) {
            $0.pinToSuperview(excluding: [.bottom])
            collectionViewHeightConstraint = $0.height.equal(
                to: 100,
                priority: .init(rawValue: 999)
            )
            $0.bottom.greaterThanOrEqual(to: bottomAnchor, priority: .defaultLow)
        }

        collectionView.backgroundColor = .clear

        setupSizeHandlers()
    }

    private func setupSizeHandlers() {
        collectionView.onChangeHandler = { [weak self] in
            guard let self = self else { return }

            guard let collectionViewHeightConstraint = self.collectionViewHeightConstraint,
                  collectionViewHeightConstraint.constant != self.collectionView.intrinsicContentSize.height else {
                      return
                  }

            collectionViewHeightConstraint.constant = self.collectionView.intrinsicContentSize.height

            self.configuration.map(self.saveBlockHeight(configuration:))

            self.configuration?.heightDidChanged()
        }
    }

    private func saveBlockHeight(configuration: DynamicLayoutConfiguration) {
        iOS14CompositionalContentHeightStorage.shared.blockHeightConstant[configuration.hashable] = self.collectionView.intrinsicContentSize.height
    }

    func update(with configuration: DynamicLayoutConfiguration) {
        self.configuration = configuration

        collectionView.collectionViewLayout = configuration.layout

        if let height = iOS14CompositionalContentHeightStorage.shared.blockHeightConstant[configuration.hashable] {
            collectionViewHeightConstraint?.constant = height
        } else {
            collectionViewHeightConstraint?.constant = collectionView.intrinsicContentSize.height
        }

        collectionViewHeightConstraint?.isActive = true
    }
}
