import UIKit


private enum SectionKind: Int, CaseIterable {
    case main
    case last

    var columnCount: Int  {
        switch self {
        case .main:
            return 6
        case .last:
            return ColorItem.text.count % 6
        }
    }
}

private enum ColorItem: Hashable {
    case text(BlockColor)
    case background(BlockBackgroundColor)
    
    var color: UIColor {
        switch self {
        case .background(let color):
            return color.color
        case .text(let color):
            return color.color
        }
    }

    static let text = BlockColor.allCases.map { ColorItem.text($0) }
    static let background = BlockBackgroundColor.allCases.map { ColorItem.background($0) }
}

extension StyleColorViewController {
    enum SelectedColorTab: Int {
        case color
        case backgroundColor
    }
}

final class StyleColorViewController: UIViewController {
    typealias ActionHandler = (_ action: BlockActionHandler.ActionType) -> Void

    // MARK: - Viwes

    private lazy var styleCollectionView: UICollectionView = {
        var config = UICollectionViewCompositionalLayoutConfiguration()

        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            guard let sectionKind = SectionKind(rawValue: sectionIndex) else { return nil }
            let columns = sectionKind.columnCount
            let itemDimension: CGSize = .init(width: 52.0, height: 52.0)


            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemDimension.width), heightDimension: .absolute(itemDimension.height))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(52.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = .fixed(0)

            let section = NSCollectionLayoutSection(group: group)

            if sectionKind == .last {
                // space for leading and trailing edge
                let edgeSpacing: CGFloat = CGFloat((SectionKind.main.columnCount - columns) * (Int(itemDimension.width) / 2))
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: edgeSpacing, bottom: 0, trailing: edgeSpacing)
            }

            return section

        }, configuration: config)

        let styleCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        styleCollectionView.backgroundColor = .white
        styleCollectionView.alwaysBounceVertical = false
        styleCollectionView.delegate = self

        return styleCollectionView
    }()

    private var colorKindSegmentControl: SimpleSegmentControl<SelectedColorTab> = .init(currentSelectedIndex: .color)

    // MARK: - Properties

    private var styleDataSource: UICollectionViewDiffableDataSource<SectionKind, ColorItem>?
    private var color: UIColor?
    private var backgroundColor: UIColor?
    private var actionHandler: ActionHandler

    private var currentColor: UIColor? {
        switch colorKindSegmentControl.selectedItemIndex {
        case .color:
            return color
        case .backgroundColor:
            return backgroundColor
        }
    }


    // MARK: - Lifecycle

    /// Init style view controller
    /// - Parameter color: Foreground color
    /// - Parameter backgroundColor: Background color
    init(color: UIColor? = .grayscale90, backgroundColor: UIColor? = .grayscaleWhite, actionHandler: @escaping ActionHandler) {
        self.actionHandler = actionHandler
        self.color = color
        self.backgroundColor = backgroundColor

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        configureStyleDataSource()
    }

    private func setupViews() {
        colorKindSegmentControl.addTarget(self, action: #selector(segmentActionHandler), for: .valueChanged)

        view.backgroundColor = .white

        colorKindSegmentControl.addSegment(title: "Color".localized)
        colorKindSegmentControl.addSegment(title: "Background".localized)

        view.addSubview(colorKindSegmentControl)
        view.addSubview(styleCollectionView)

        setupLayout()
    }

    private func setupLayout() {
        styleCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorKindSegmentControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            colorKindSegmentControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            colorKindSegmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorKindSegmentControl.heightAnchor.constraint(equalToConstant: 28),
            
            styleCollectionView.topAnchor.constraint(equalTo: colorKindSegmentControl.bottomAnchor, constant: 12),
            styleCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            styleCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            styleCollectionView.heightAnchor.constraint(equalToConstant: 104).usingPriority(.defaultHigh - 1),
            styleCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        ])
    }

    private func configureStyleDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<StyleColorCellView, ColorItem> { (cell, indexPath, item) in
            var content = StyleColorCellContentConfiguration()
            content.color = item.color
            cell.contentConfiguration = content
        }

        styleDataSource = UICollectionViewDiffableDataSource<SectionKind, ColorItem>(collectionView: styleCollectionView) {
            [weak self] (collectionView: UICollectionView, indexPath: IndexPath, identifier: ColorItem) -> UICollectionViewCell? in

            if identifier.color == self?.currentColor {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        // initial data
        updateSnapshot(with: ColorItem.text)
    }

    @objc private func segmentActionHandler() {
        switch colorKindSegmentControl.selectedItemIndex {
        case .color:
            updateSnapshot(with: ColorItem.text)
        case .backgroundColor:
            updateSnapshot(with: ColorItem.background)
        }
    }

    private func updateSnapshot(with colorItems: [ColorItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, ColorItem>()

        let itemsInLastSection = colorItems.count % SectionKind.main.columnCount

        snapshot.appendSections([.main])
        snapshot.appendItems(colorItems.dropLast(itemsInLastSection))

        if itemsInLastSection != 0 {
            snapshot.appendSections([.last])
            snapshot.appendItems(colorItems.suffix(itemsInLastSection))
        }

        styleDataSource?.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - UICollectionViewDelegate

extension StyleColorViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard collectionView.indexPathsForSelectedItems?.first != indexPath else { return false }
        guard let colorItem = styleDataSource?.itemIdentifier(for: indexPath) else {
            return false
        }
        collectionView.deselectAllSelectedItems()
        
        switch colorItem {
        case .text(let color):
            self.color = color.color
            actionHandler(.setTextColor(color))
        case .background(let color):
            self.backgroundColor = color.color
            actionHandler(.setBackgroundColor(color))
        }
        
        return true
    }
}
