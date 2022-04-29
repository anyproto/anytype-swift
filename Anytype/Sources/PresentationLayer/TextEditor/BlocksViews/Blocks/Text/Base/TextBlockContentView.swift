import UIKit
import Combine
import BlocksModels


final class TextBlockContentView: UIView, BlockContentView {

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

        textView.widthAnchor.constraint(lessThanOrEqualTo: textView.widthAnchor, constant: 24).isActive = true

        contentView.addSubview(contentStackView) {
            topContentConstraint = $0.top.equal(to: contentView.topAnchor)
            bottomContentnConstraint = $0.bottom.equal(to: contentView.bottomAnchor)
            $0.leading.equal(to: contentView.leadingAnchor)
            $0.trailing.equal(to: contentView.trailingAnchor)
        }

        createEmptyBlockButton.layoutUsing.anchors {
            $0.height.equal(to: 26)
        }

        mainStackView.addArrangedSubview(contentView)
        mainStackView.addArrangedSubview(createEmptyBlockButton)

        addSubview(mainStackView) {
            $0.pinToSuperview()
        }
    }

    // MARK: - Apply configuration
    
    private func applyNewConfiguration(configuration: TextBlockContentConfiguration) {
        textView.textView.textStorage.setAttributedString(configuration.content.anytypeText.attrString)

        let restrictions = BlockRestrictionsBuilder.build(textContentType: configuration.content.contentType)
        
        TextBlockLeftViewStyler.applyStyle(contentStackView: contentStackView, configuration: configuration)

        textBlockLeadingView.update(style: .init(with: configuration))

        TextBlockTextViewStyler.applyStyle(textView: textView, configuration: configuration, restrictions: restrictions)

        updateAllConstraint(blockTextStyle: configuration.content.contentType)
        
        textView.delegate = self
        
        let displayPlaceholder = configuration.content.contentType == .toggle && configuration.shouldDisplayPlaceholder
        createEmptyBlockButton.isHidden = !displayPlaceholder

        focusSubscription = configuration.focusPublisher.sink { [weak self] focus in
            self?.textView.setFocus(focus)
        }
    }
    
    private func updateAllConstraint(blockTextStyle: BlockText.Style) {
        let contentInset = TextBlockLayout.contentInset(textBlockStyle: blockTextStyle)

        topContentConstraint?.constant = contentInset.top
        bottomContentnConstraint?.constant = contentInset.bottom
    }
}

private extension TextBlockContentView {
    
    static func makeMainStackView() -> UIStackView {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.alignment = .leading
        return mainStackView
    }
    
    static func makeContentStackView() -> UIStackView {
        let contentStackView = UIStackView()
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fill
        contentStackView.spacing = 4
        contentStackView.alignment = .top
        return contentStackView
    }
    
}
