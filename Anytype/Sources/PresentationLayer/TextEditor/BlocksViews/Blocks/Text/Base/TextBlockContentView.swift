import UIKit
import Combine
import Services


final class TextBlockContentView: UIView, BlockContentView, DynamicHeightView, FirstResponder {
    var isFirstResponderValueChangeHandler: ((Bool) -> Void)?
    
    // MARK: - DynamicHeightView
    var heightDidChanged: (() -> Void)?
    
    // MARK: - Views
    private let contentView = UIView()
    private(set) lazy var textView = CustomTextView()
    private(set) lazy var createEmptyBlockButton = EmptyToggleButtonBuilder.create { [weak self] in
        self?.actions?.createEmptyBlock()
    }
    private lazy var textBlockLeadingView = TextBlockLeadingView()
    
    private let mainStackView: UIStackView = makeMainStackView()
    private let contentStackView: UIStackView = makeContentStackView()
    
    private var topContentConstraint: NSLayoutConstraint?
    private var bottomContentnConstraint: NSLayoutConstraint?
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
        contentStackView.addArrangedSubview(textBlockLeadingView)
        contentStackView.addArrangedSubview(textView)
            
        contentView.addSubview(contentStackView) {
            topContentConstraint = $0.top.equal(to: contentView.topAnchor)
            bottomContentnConstraint = $0.bottom.greaterThanOrEqual(to: contentView.bottomAnchor)
            $0.leading.equal(to: contentView.leadingAnchor)
            $0.trailing.equal(to: contentView.trailingAnchor)
        }
        
        textBlockLeadingView.layoutUsing.anchors {
            $0.top.equal(to: contentStackView.topAnchor)
            $0.bottom.equal(to: contentStackView.bottomAnchor)
        }
        
        
        textView.layoutUsing.anchors {
            $0.trailing.equal(to: contentStackView.trailingAnchor)
            $0.top.equal(to: contentStackView.topAnchor)
            $0.leading.equal(to: textBlockLeadingView.trailingAnchor)
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
        printTimeElapsedWhenRunningCode(title: "Text Block setAttributedString") {
            textView.textView.textStorage.setAttributedString(configuration.attributedString)
        }

        printTimeElapsedWhenRunningCode(title: "TextBlockLeftViewStyler.applyStyle") {
            TextBlockLeftViewStyler.applyStyle(contentStackView: contentStackView, configuration: configuration)
        }
        
        
        // Make it state
        printTimeElapsedWhenRunningCode(title: "Leading view") {
            textBlockLeadingView.update(style: .init(with: configuration))
        }
        
        printTimeElapsedWhenRunningCode(title: "TextBlockTextViewStyler.applyStyle") {
            let restrictions = BlockRestrictionsBuilder.build(textContentType: configuration.content.contentType)
            TextBlockTextViewStyler.applyStyle(textView: textView, configuration: configuration, restrictions: restrictions)
        }
       
        //
        
        printTimeElapsedWhenRunningCode(title: "updateAllConstraint") {
            updateAllConstraint(blockTextStyle: configuration.content.contentType)
        }
        
        //
        textView.delegate = self
        
        printTimeElapsedWhenRunningCode(title: "createEmptyBlockButton.isHidden") {
            let displayPlaceholder = configuration.content.contentType == .toggle && configuration.shouldDisplayPlaceholder
            createEmptyBlockButton.isHidden = !displayPlaceholder
        }
        
        focusSubscription = configuration
            .focusPublisher
            .sink { [weak self] focus in
                print("Someone wants to set focus \(focus)")
                DispatchQueue.main.async {
                    self?.textView.textView.setFocus(focus)
                }
                
        }
        
        resetSubscription = configuration.resetPublisher.sink { [weak self] configuration in
            configuration.map {
                self?.applyNewConfiguration(configuration: $0)
            }
        }
        
        if let position = configuration.initialBlockFocusPosition {
            print("Someone wants to set initial focus \(position)")

            textView.textView.setFocus(position)
        }        
    }
    
    private func updateAllConstraint(blockTextStyle: BlockText.Style) {
        let contentInset = TextBlockLayout.contentInset(textBlockStyle: blockTextStyle)
        
        topContentConstraint?.constant = contentInset.top
        bottomContentnConstraint?.constant = -contentInset.bottom
    }
}

private extension TextBlockContentView {
    
    static func makeMainStackView() -> UIStackView {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        return mainStackView
    }
    
    static func makeContentStackView() -> UIStackView {
        let contentStackView = UIStackView()
        contentStackView.axis = .horizontal
        contentStackView.distribution = .equalSpacing
        contentStackView.spacing = 4
        contentStackView.alignment = .leading
        return contentStackView
    }
    
}
