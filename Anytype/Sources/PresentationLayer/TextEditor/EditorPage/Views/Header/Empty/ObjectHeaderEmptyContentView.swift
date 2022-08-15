import UIKit

final class ObjectHeaderEmptyContentView: UIView, UIContentView {
        
    // MARK: - Private variables

    private var appliedConfiguration: ObjectHeaderEmptyConfiguration!
    
    private let tapGesture: BindableGestureRecognizer
    
    // MARK: - Internal variables
    
    var configuration: UIContentConfiguration {
        get { self.appliedConfiguration }
        set { return }
    }
    
    // MARK: - Initializers
    
    init(configuration: ObjectHeaderEmptyConfiguration) {
        appliedConfiguration = configuration
        tapGesture = BindableGestureRecognizer { _ in configuration.data.onTap() }
        
        super.init(frame: .zero)

        isUserInteractionEnabled = !configuration.isLocked
        backgroundColor = .backgroundPrimary
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension ObjectHeaderEmptyContentView  {
    
    func setupView() {
        setupLayout()
        addGestureRecognizer(tapGesture)
    }
    
    func setupLayout() {
        let emptyView = UIView()

        addSubview(emptyView) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.bottom.equal(to: bottomAnchor, priority: .init(rawValue: 999))
            $0.height.equal(to: ObjectHeaderConstants.emptyViewHeight)
        }
    }
}
