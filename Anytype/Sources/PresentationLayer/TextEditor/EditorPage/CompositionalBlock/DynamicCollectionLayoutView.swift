import UIKit
import Services

// Used only for iOS14.
@MainActor
private final class iOS14CompositionalContentHeightStorage {
    static let shared = iOS14CompositionalContentHeightStorage()

    var blockHeightConstant = [AnyHashable: CGFloat]()
}

struct DynamicLayoutConfiguration: Hashable {
    enum LayoutHeightMemory {
        case none
        case hashable(AnyHashable)
    }

    let layoutHeightMemory: LayoutHeightMemory
    @EquatableNoop var layout: UICollectionViewLayout
    @EquatableNoop var heightDidChanged: () -> Void

    static func == (lhs: DynamicLayoutConfiguration, rhs: DynamicLayoutConfiguration) -> Bool {
        switch (lhs.layoutHeightMemory, rhs.layoutHeightMemory) {
        case let (.hashable(lhsHash), .hashable(rhsHash)):
            return lhsHash == rhsHash
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch layoutHeightMemory {
        case .none:
            break
        case .hashable(let anyHashable):
            hasher.combine(anyHashable)
        }
    }
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
        switch configuration.layoutHeightMemory {
        case .none:
            return
        case .hashable(let hashValue):
            iOS14CompositionalContentHeightStorage.shared.blockHeightConstant[hashValue] = self.collectionView.intrinsicContentSize.height
        }
    }

    func update(with configuration: DynamicLayoutConfiguration) {
        self.configuration = configuration

        collectionView.collectionViewLayout = configuration.layout

        switch configuration.layoutHeightMemory {
        case let .hashable(hashable):
            if let height = iOS14CompositionalContentHeightStorage.shared.blockHeightConstant[hashable] {
                collectionViewHeightConstraint?.constant = height
            } else {
                collectionViewHeightConstraint?.constant = collectionView.intrinsicContentSize.height
            }
        case .none:
            return
        }

        collectionViewHeightConstraint?.isActive = true
    }
}
