import UIKit
import BlocksModels
import AnytypeCore

// Used only for iOS14.
private final class iOS14CompositionalContentHeightStorage {
    static let shared = iOS14CompositionalContentHeightStorage()

    var blockHeightConstant = [AnyHashable: CGFloat]()
}

final class AnytypeCollectionViewDataSource {
    var views: [[ContentConfigurationProvider]]

    let dataSource: UICollectionViewDiffableDataSource<DynamicCollectionSection, DynamicCollectionItem> = makeCollectionViewDataSource()
    

//    func createCellRegistration() -> UICollectionView.CellRegistration<EditorViewListCell, BlockViewModelProtocol> {
//        .init { [weak self] cell, indexPath, item in
//            self?.setupCell(cell: cell, indexPath: indexPath, item: item)
//        }
//    }
//
//    func createSystemCellRegistration() -> UICollectionView.CellRegistration<EditorViewListCell, SystemContentConfiguationProvider> {
//        .init { (cell, indexPath, item) in
//            cell.contentConfiguration = item.makeContentConfiguration(maxWidth: cell.bounds.width)
//        }
//    }
//
    func setupCell(
        cell: UICollectionViewListCell,
        indexPath: IndexPath,
        item: ContentConfigurationProvider
    ) {
        cell.contentConfiguration = item.makeContentConfiguration(maxWidth: cell.bounds.width)
        cell.contentView.isUserInteractionEnabled = true

        cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        if FeatureFlags.rainbowViews {
            cell.fillSubviewsWithRandomColors(recursively: false)
        }
    }
//
//    private func createHeaderCellRegistration() -> UICollectionView.CellRegistration<EditorViewListCell, ObjectHeader> {
//        .init { [weak self] cell, _, item in
//            guard let self = self else { return }
//            let contentConfiguration = item.makeContentConfiguration(maxWidth: cell.bounds.width)
//
//            if var objectHeaderFilledConfiguration = contentConfiguration as? ObjectHeaderFilledConfiguration {
//                let topAdjustedContentInset = self.collectionView.adjustedContentInset.top
//                objectHeaderFilledConfiguration.topAdjustedContentInset = topAdjustedContentInset
//                cell.contentConfiguration = objectHeaderFilledConfiguration
//            } else {
//                cell.contentConfiguration = contentConfiguration
//            }
//        }
//    }


    func update(changes: CollectionDifference<DynamicCollectionItem>?) {
        

        
        if let changes = changes {
            for change in changes.insertions {
                guard dataSour.isVisible(change.element) else { continue }

                reloadCell(for: change.element)
            }
        }
    }

    func update(
        changes: CollectionDifference<EditorItem>?,
        allModels: [EditorItem]
    ) {
        var blocksSnapshot = NSDiffableDataSourceSectionSnapshot<EditorItem>()
        blocksSnapshot.append(allModels)

        if let changes = changes {
            for change in changes.insertions {
                guard blocksSnapshot.isVisible(change.element) else { continue }

                reloadCell(for: change.element)
            }
        }

        let animatingDifferences = (changes?.canPerformAnimation ?? true) && didAppliedModelsOnce
        applyBlocksSectionSnapshot(blocksSnapshot, animatingDifferences: animatingDifferences)
    }

    func makeCollectionViewDataSource() -> UICollectionViewDiffableDataSource<DynamicCollectionSection, DynamicCollectionItem> {
        let headerCellRegistration = createHeaderCellRegistration()
        let cellRegistration = createCellRegistration()
        let systemCellRegistration = createSystemCellRegistration()

        let dataSource = UICollectionViewDiffableDataSource<EditorSection, EditorItem>(
            collectionView: collectionView
        ) { [weak self] (collectionView, indexPath, dataSourceItem) -> UICollectionViewCell? in
            let cell: UICollectionViewCell
            switch dataSourceItem {
            case let .block(block):
                cell = collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: block
                )
            case let .header(header):
                return collectionView.dequeueConfiguredReusableCell(
                    using: headerCellRegistration,
                    for: indexPath,
                    item: header
                )
            case let .system(configuration):
                return collectionView.dequeueConfiguredReusableCell(
                    using: systemCellRegistration,
                    for: indexPath,
                    item: configuration
                )
            }

            // UIKit bug. isSelected works fine, UIConfigurationStateCustomKey properties sometimes switch to adjacent cellsAnytype/Sources/PresentationLayer/TextEditor/BlocksViews/Base/CustomStateKeys.swift
            if let self = self {
                (cell as? EditorViewListCell)?.isMoving = self.collectionView.indexPathsForMovingItems.contains(indexPath)
                (cell as? EditorViewListCell)?.isLocked = self.collectionView.isLocked
            }


            return cell
        }

        var initialSnapshot = NSDiffableDataSourceSnapshot<EditorSection, EditorItem>()
        initialSnapshot.appendSections(EditorSection.allCases)

        dataSource.apply(initialSnapshot, animatingDifferences: false)

        return dataSource
    }

}

struct DynamicLayoutConfiguration: Hashable {
    let hashable: AnyHashable

    @EquatableNoop var dataSource: AnytypeCollectionViewDataSource
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
        collectionView.dataSource = configuration.dataSource

        collectionView.reloadItems(at: [IndexPath(row: 0, section: 0)])

        if let height = iOS14CompositionalContentHeightStorage.shared.blockHeightConstant[configuration.hashable] {
            collectionViewHeightConstraint?.constant = height
        } else {
            collectionViewHeightConstraint?.constant = collectionView.intrinsicContentSize.height
        }

        collectionViewHeightConstraint?.isActive = true
    }
}
