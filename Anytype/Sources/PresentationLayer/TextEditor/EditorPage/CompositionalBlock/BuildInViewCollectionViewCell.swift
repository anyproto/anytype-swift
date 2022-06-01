import UIKit

//final class TableBlockComponentConfiguration<T: BlockConfiguration>: BlockConfiguration {
//    typealias View = TableBlockComponentView
//
//    let blockConfiguration: T
//}
//
//final class TableBlockComponentView: UIView, BlockContentView {
//    private lazy var innerView:
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        setup()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//
//        setup()
//    }
//
//    func update(with configuration: TableBlockComponentConfiguration) {
//        componentView.update(with: configuration)
//    }
//
//    private func setup() {
//        addSubview(componentView) {
//            $0.pinToSuperview(excluding: [.bottom])
//            $0.bottom.greaterThanOrEqual(to: bottomAnchor, priority: .init(rawValue: 999))
//        }
//    }
//}

class GenericCollectionViewCell<Component: BlockContentView>: UICollectionViewCell {
    private lazy var componentView = Component(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        print("+--+ override init(frame: CGRect) \(self)")
        setup()
    }

    override var reuseIdentifier: String? {
        return Component.reusableIdentifier
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    override func prepareForReuse() {
        print("+--+ prepareForReuse \(self)")

        super.prepareForReuse()
    }

    func update(with configuration: Component.Configuration) {
        componentView.update(with: configuration)
    }

    private func setup() {
        addSubview(componentView) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.bottom.greaterThanOrEqual(to: bottomAnchor, priority: .init(rawValue: 999))
        }
    }
}
