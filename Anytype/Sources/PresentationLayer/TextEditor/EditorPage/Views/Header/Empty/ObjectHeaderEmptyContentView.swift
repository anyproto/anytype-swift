import UIKit

final class ObjectHeaderEmptyContentView: UIView, BlockContentView {
    // MARK: - Private variables
    private let emptyView = UIView()
    private let tapGesture = BindableGestureRecognizer()
    
    private var heightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
    }

    func update(with state: UICellConfigurationState) {
        tapGesture.isEnabled = !state.isLocked
    }

    func update(with configuration: ObjectHeaderEmptyConfiguration) {
        tapGesture.action = { _ in
            configuration.data.onTap()
        }
        
        switch configuration.data.presentationStyle {
        case .full:
            let bannerPadding = configuration.showPublishingBanner ? 40 : 0
            heightConstraint?.constant = bannerPadding + ObjectHeaderConstants.emptyViewHeight
        case .embedded:
            heightConstraint?.constant = ObjectHeaderConstants.emptyViewHeightCompact
        }
    }
}

private extension ObjectHeaderEmptyContentView  {
    
    func setupView() {
        backgroundColor = .Background.primary
        setupLayout()
        addGestureRecognizer(tapGesture)
    }
    
    func setupLayout() {
        addSubview(emptyView) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.bottom.greaterThanOrEqual(to: bottomAnchor, priority: .init(999))
            heightConstraint = $0.height.equal(to: ObjectHeaderConstants.emptyViewHeight)
        }
    }
}
