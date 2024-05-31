import UIKit
import Combine
import Services


final class TextBlockContentView: UIView, BlockContentView, DynamicHeightView, FirstResponder {
    var isFirstResponderValueChangeHandler: ((Bool) -> Void)?
    
    // MARK: - DynamicHeightView
    var heightDidChanged: (() -> Void)?
    
    // MARK: - Views
    private let contentView = UIView()
    private let textContainerView = UIView()
    private(set) lazy var textView = CustomTextView()
    private(set) lazy var createEmptyBlockButton = EmptyToggleButtonBuilder.create { [weak self] in
        self?.actions?.createEmptyBlock()
    }
    private lazy var textBlockLeadingView = TextBlockLeadingView()
    
    private let mainStackView: UIStackView = makeMainStackView()
    
    private var topContentConstraint: NSLayoutConstraint?
    private var bottomContentnConstraint: NSLayoutConstraint?
    private var contentSpacingConstraint: NSLayoutConstraint?
    private var focusSubscription: AnyCancellable?
    private var resetSubscription: AnyCancellable?
    
    private(set) var actions: TextBlockContentConfiguration.Actions?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupLayout()
    }
    
    func update(with configuration: TextBlockContentConfiguration) {
        actions = configuration.actions
        applyNewConfiguration(configuration: configuration)
    }
    
    func update(with state: UICellConfigurationState) {
        textView.textView.isLockedForEditing = state.isLocked
        createEmptyBlockButton.isEnabled = !state.isLocked
        textBlockLeadingView.checkboxView?.isUserInteractionEnabled = !state.isLocked
        textBlockLeadingView.calloutIconView?.isUserInteractionEnabled = !state.isLocked
        textView.textView.isUserInteractionEnabled = state.isEditing
    }
    
    // MARK: - Setup views
    
    private func setupLayout() {
        textContainerView.addSubview(textBlockLeadingView) {
            $0.pinToSuperview(excluding: [.right])
        }
        textContainerView.addSubview(textView) {
            $0.pinToSuperview(excluding: [.left])
            // For textBlockLeadingView is visible
            contentSpacingConstraint = $0.leading.equal(to: textBlockLeadingView.trailingAnchor, priority: .required)
            // For textBlockLeadingView is hidden
            $0.leading.equal(to: textContainerView.leadingAnchor, priority: .defaultHigh)
        }
            
        contentView.addSubview(textContainerView) {
            topContentConstraint = $0.top.equal(to: contentView.topAnchor)
            bottomContentnConstraint = $0.bottom.greaterThanOrEqual(to: contentView.bottomAnchor)
            $0.leading.equal(to: contentView.leadingAnchor)
            $0.trailing.equal(to: contentView.trailingAnchor)
        }
        
        createEmptyBlockButton.layoutUsing.anchors {
            $0.height.equal(to: 26)
        }
        
        mainStackView.addArrangedSubview(contentView)
        contentView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor).isActive = true
        
        mainStackView.addArrangedSubview(createEmptyBlockButton)
        
        addSubview(mainStackView) {
            $0.pinToSuperview()
        }
    }
    
    // MARK: - Apply configuration
    
    private func applyNewConfiguration(configuration: TextBlockContentConfiguration) {
        textView.textView.textStorage.setAttributedString(configuration.attributedString)
                
        textBlockLeadingView.update(blockId: configuration.blockId, style: TextBlockLeadingStyle(with: configuration))
    
        let restrictions = BlockRestrictionsBuilder.build(textContentType: configuration.content.contentType)
        TextBlockTextViewStyler.applyStyle(textView: textView, configuration: configuration, restrictions: restrictions)
        
        updateAllConstraint(configuration: configuration)
        textView.delegate = self
        
        let displayPlaceholder = configuration.content.contentType == .toggle && configuration.shouldDisplayPlaceholder
        createEmptyBlockButton.isHidden = !displayPlaceholder
        
        focusSubscription = configuration
            .focusPublisher
            .receiveOnMain()
            .sink { [weak self] focus in
                self?.textView.textView.setFocus(focus)
            }
        
        resetSubscription = configuration.resetPublisher.sink { [weak self] configuration in
            configuration.map {
                self?.applyNewConfiguration(configuration: $0)
            }
        }
        
        if let position = configuration.initialBlockFocusPosition {
            textView.textView.setFocus(position)
        }        
    }
    
    private func updateAllConstraint(configuration: TextBlockContentConfiguration) {
        let contentInset = TextBlockLayout.contentInset(textBlockStyle: configuration.content.contentType)
        
        topContentConstraint?.constant = contentInset.top
        bottomContentnConstraint?.constant = -contentInset.bottom
        
        if textBlockLeadingView.isHidden {
            contentSpacingConstraint?.constant = 0
        } else if configuration.content.contentType == .title, configuration.isCheckable {
            contentSpacingConstraint?.constant = 8
        } else {
            contentSpacingConstraint?.constant = 4
        }
    }
}

private extension TextBlockContentView {
    
    static func makeMainStackView() -> UIStackView {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        return mainStackView
    }
}
