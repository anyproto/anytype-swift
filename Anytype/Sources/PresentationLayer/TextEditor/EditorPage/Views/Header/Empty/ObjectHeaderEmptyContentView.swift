import UIKit

final class ObjectHeaderEmptyContentView: UIView, BlockContentView {
    // MARK: - Private variables
    private let emptyView = UIView()
    private let tapGesture = BindableGestureRecognizer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupLayout()
    }

    func update(with state: UICellConfigurationState) {
        tapGesture.isEnabled = !state.isLocked
    }

    func update(with configuration: ObjectHeaderEmptyConfiguration) {
        tapGesture.action = { _ in
            configuration.data.onTap()
        }
    }
}

private extension ObjectHeaderEmptyContentView  {
    
    func setupView() {
        backgroundColor = .backgroundPrimary
        setupLayout()
        addGestureRecognizer(tapGesture)
    }
    
    func setupLayout() {
        addSubview(emptyView) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.bottom.equal(to: bottomAnchor, priority: .init(rawValue: 999))
            $0.height.equal(to: ObjectHeaderConstants.emptyViewHeight)
        }
    }
}
