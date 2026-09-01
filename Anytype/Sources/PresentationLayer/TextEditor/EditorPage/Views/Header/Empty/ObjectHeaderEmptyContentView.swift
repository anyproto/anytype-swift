import UIKit

final class ObjectHeaderEmptyContentView: UIView, BlockContentView {
    // MARK: - Private variables
    private let emptyView = UIView()

    private var heightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
    }

    func update(with configuration: ObjectHeaderEmptyConfiguration) {
        let bannerPadding: CGFloat = configuration.showPublishingBanner ? 40 : 0
        heightConstraint?.constant = configuration.data.presentationStyle.height + bannerPadding
    }
}

private extension ObjectHeaderEmptyContentView  {
    
    func setupView() {
        backgroundColor = .Background.primary
        setupLayout()
    }
    
    func setupLayout() {
        addSubview(emptyView) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.bottom.greaterThanOrEqual(to: bottomAnchor, priority: .init(999))
            heightConstraint = $0.height.equal(to: ObjectHeaderConstants.emptyViewHeight)
        }
    }
}
