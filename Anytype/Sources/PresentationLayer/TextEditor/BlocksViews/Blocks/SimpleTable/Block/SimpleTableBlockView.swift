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
