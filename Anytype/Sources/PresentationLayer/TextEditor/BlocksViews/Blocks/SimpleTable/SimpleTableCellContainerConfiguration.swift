import UIKit

// Would be rewrited to same generic behaviour to use reusable feature properly
final class SimpleTableCellConfiguration: BlockConfiguration {
    typealias View = SimpleTableCellContainerView

    lazy var view: UIView = viewHandler()
    let backgroundColor: UIColor?
    let hashable: AnyHashable

    @EquatableNoop var onHeightDidChange: ((AnyHashable) -> Void)?
    @EquatableNoop private var viewHandler: () -> UIView

    init<Item: BlockConfiguration>(
        item: Item,
        backgroundColor: UIColor?
    ) {
        self.hashable = item.hashValue as AnyHashable
        self.backgroundColor = backgroundColor

        let itemView = Item.View(frame: .zero)

        self.viewHandler = {
            itemView.update(with: item)

            return itemView
        }

        itemView.onHeightDidChange = { [weak self] in
            self?.onHeightDidChange?(item.hashValue)
        }
    }

    static func == (lhs: SimpleTableCellConfiguration, rhs: SimpleTableCellConfiguration) -> Bool {
        lhs.hashable == rhs.hashable
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(hashable)
    }
}
