import UIKit
import BlocksModels
import Combine

final class SimpleTableBlockView: UIView, BlockContentView {
    private lazy var dynamicLayoutView = DynamicCollectionLayoutView(frame: .zero)
    private lazy var spreadsheetLayout = SpreadsheetLayout(dataSource: dataSource)
    private lazy var dataSource = SpreadsheetViewDataSource(
        collectionView: dynamicLayoutView.collectionView
    )

    private var viewModel: SimpleTableViewModel?
    private var modelsSubscriptions = [AnyCancellable]()
    private var configuration: SimpleTableBlockContentConfiguration?
    private weak var blockDelegate: BlockDelegate?

    private var cancellables = [AnyCancellable]()

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

        dynamicLayoutView.update(
            with: .init(
                hashable: configuration.hashValue,
                layout: spreadsheetLayout,
                heightDidChanged: { [weak self] in self?.blockDelegate?.textBlockSetNeedsLayout() }
            )
        )

        modelsSubscriptions.removeAll()
        viewModel?.$widths.sink { [weak spreadsheetLayout] width in
            spreadsheetLayout?.itemWidths = width
        }.store(in: &modelsSubscriptions)

        spreadsheetLayout.relativePositionProvider = configuration.relativePositionProvider

        viewModel?.dataSource = dataSource
    }

    override func endEditing(_ force: Bool) -> Bool {
        super.endEditing(force)
    }

    private func setupHandlers() {
        viewModel?.stateManager.editorEditingStatePublisher.sink { [unowned self] state in
            switch state {
            case .selecting:
                dynamicLayoutView.collectionView.isEditing = false
                dynamicLayoutView.collectionView.isLocked = false
            case .editing:
                dynamicLayoutView.collectionView.isEditing = true
                dynamicLayoutView.collectionView.isLocked = false
            case .moving:
                fatalError()
            case .locked, .simpleTablesSelection:
                dynamicLayoutView.collectionView.isEditing = false
                dynamicLayoutView.collectionView.isLocked = true
            }
        }.store(in: &cancellables)

        viewModel?.stateManager.editorSelectedBlocks.sink { [unowned self] blockIds in
            blockIds.forEach(selectBlock)
        }.store(in: &cancellables)
    }

    private func selectBlock(blockId: BlockId) {
        guard let indexPath = dataSource.indexPath(for: blockId) else {
            return
        }

        dynamicLayoutView.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
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
