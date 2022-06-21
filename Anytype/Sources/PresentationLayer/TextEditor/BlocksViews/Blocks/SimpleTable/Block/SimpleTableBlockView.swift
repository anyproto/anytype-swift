import UIKit
import BlocksModels
import Combine

final class SimpleTableBlockView: UIView, BlockContentView {
    private let dataSource = AnytypeCollectionViewDataSource(views: [])
    private lazy var dynamicLayoutView = DynamicCollectionLayoutView(frame: .zero)
    private lazy var spreadsheetLayout = SpreadsheetLayout()

    private var viewModel: SimpleTableViewModel?
    private var heightDidChangedSubscriptions = [AnyCancellable]()
    private var modelsSubscriptions = [AnyCancellable]()
    private var configuration: SimpleTableBlockContentConfiguration?
    private weak var blockDelegate: BlockDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubview()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupSubview()
    }

    func prepareForReuse() {
        modelsSubscriptions.removeAll()
    }

    func update(with configuration: SimpleTableBlockContentConfiguration) {
        self.blockDelegate = configuration.blockDelegate
        self.configuration = configuration

        viewModel = configuration.viewModelBuilder()

        modelsSubscriptions.removeAll()

        viewModel?.$cells.sink { [weak self] items in
            self?.spreadsheetLayout.setItems(items: items)
            self?.dataSource.views = items
//            self?.dynamicLayoutView.collectionView
            self?.dynamicLayoutView.collectionView.reloadData()

//            if self?.dynamicLayoutView.collectionView.visibleCells.count > 0 {
//                self?.dynamicLayoutView.collectionView.reloadItems(at: <#T##[IndexPath]#>)
//            } else {
//                self?.dynamicLayoutView.collectionView.reloadData()
//            }

            self?.setupHeightChangeHandlers(items: items)
        }.store(in: &modelsSubscriptions)

        viewModel?.$widths.sink { [weak self] width in
            self?.spreadsheetLayout.itemWidths = width
        }.store(in: &modelsSubscriptions)

        viewModel?.onDataSourceUpdate = { [weak self] items in
            self?.dataSource.views = items
        }

        spreadsheetLayout.relativePositionProvider = configuration.relativePositionProvider

        dynamicLayoutView.update(
            with: .init(
                hashable: AnyHashable(configuration),
                dataSource: dataSource,
                layout: spreadsheetLayout,
                heightDidChanged: { [weak self] in self?.blockDelegate?.textBlockSetNeedsLayout() }
            )
        )
    }

    private func setupHeightChangeHandlers(items: [[SimpleTableBlockProtocol]]) {
        heightDidChangedSubscriptions.removeAll()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            for (sectionIndex, section) in items.enumerated() {
                for (rowIndex, element) in section.enumerated() {
                    element.heightDidChangedSubject.sink { [weak self] in
                        let indexPath = IndexPath(row: rowIndex, section: sectionIndex)

                        self?.spreadsheetLayout.setNeedsLayout(indexPath: indexPath)

                        self?.spreadsheetLayout.invalidateLayout()
                        self?.dynamicLayoutView.layoutIfNeeded()

                    }.store(in: &self.heightDidChangedSubscriptions)
                }
            }
        }
    }

    private func setupSubview() {
        addSubview(dynamicLayoutView) {
            $0.pinToSuperview(insets: .init(top: 10, left: 0, bottom: 0, right: 0))
        }

        dynamicLayoutView.collectionView.contentInset = .init(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )
    }
}
