import UIKit
import BlocksModels
import Combine

final class SimpleTableBlockView: UIView, BlockContentView {
    private lazy var dynamicLayoutView = DynamicCompositionalLayoutView(frame: .zero)
    private lazy var spreadsheetLayout = SpreadsheetLayout()
    private var resetSubscription: AnyCancellable?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubview()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupSubview()
    }

    func update(with configuration: SimpleTableBlockContentConfiguration) {
        dynamicLayoutView.collectionView.register(
            GenericCollectionViewCell<SimpleTableCellContainerView>.self,
            forCellWithReuseIdentifier: SimpleTableCellContainerView.reusableIdentifier
        )

        spreadsheetLayout.itemWidths = configuration.widths
        spreadsheetLayout.items = configuration.items
        spreadsheetLayout.relativePositionProvider = configuration.relativePositionProvider

        dynamicLayoutView.update(
            with: .init(
                hashable: AnyHashable(configuration),
                views: configuration.items,
                compositionalLayout: spreadsheetLayout,
                heightDidChanged: configuration.heightDidChanged
            )
        )

        dynamicLayoutView.collectionView.contentInset = .init(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )
    }

    private func setupSubview() {
        addSubview(dynamicLayoutView) {
            $0.pinToSuperview()
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
