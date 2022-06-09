import UIKit
import BlocksModels

final class SimpleTableBlockView: UIView, BlockContentView {
    private lazy var dynamicLayoutView = DynamicCollectionLayoutView(frame: .zero)
    private lazy var spreadsheetLayout = SpreadsheetLayout()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubview()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupSubview()
    }

    func update(with configuration: SimpleTableBlockContentConfiguration) {
        spreadsheetLayout.itemWidths = configuration.widths
        spreadsheetLayout.items = configuration.items
        spreadsheetLayout.relativePositionProvider = configuration.relativePositionProvider

        dynamicLayoutView.update(
            with: .init(
                hashable: AnyHashable(configuration),
                views: configuration.items,
                layout: spreadsheetLayout,
                heightDidChanged: configuration.heightDidChanged
            )
        )
    }

    private func setupSubview() {
        addSubview(dynamicLayoutView) {
            $0.pinToSuperview()
        }

        dynamicLayoutView.collectionView.contentInset = .init(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )

        dynamicLayoutView.collectionView.register(
            SimpleTableCollectionViewCell<TextBlockContentView>.self,
            forCellWithReuseIdentifier: SimpleTableCellConfiguration<TextBlockContentConfiguration>.reusableIdentifier
        )
    }
}
