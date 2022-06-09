import UIKit

class GenericCollectionViewCell<Component: BlockContentView>: UICollectionViewCell {
    private let componentView = Component(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
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
