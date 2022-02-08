import UIKit
import Combine
import BlocksModels


final class TextBlockContentView: BaseBlockView<TextBlockContentConfiguration> {
    
    // MARK: - Views
    
    private let backgroundColorView = UIView()
    private let contentView = UIView()
    private(set) lazy var textView = CustomTextView()
    private(set) lazy var createEmptyBlockButton = EmptyToggleButtonBuilder.create { [weak self] in
        guard let self = self else { return }
        let blockId = self.currentConfiguration.information.id
        self.currentConfiguration.actionHandler.createEmptyBlock(parentId: blockId)
    }
    
    private let mainStackView: UIStackView = makeMainStackView()
    private let contentStackView: UIStackView = makeContentStackView()
    
    private var topMainConstraint: NSLayoutConstraint?
    private var bottomMainConstraint: NSLayoutConstraint?
    
    private var topContentConstraint: NSLayoutConstraint?
    private var bottomContentnConstraint: NSLayoutConstraint?

    private var focusSubscription: AnyCancellable?
    
    override func setupSubviews() {
        super.setupSubviews()

        setupLayout()
    }

    override func update(with configuration: TextBlockContentConfiguration) {
        super.update(with: configuration)

        applyNewConfiguration()
    }

    override func update(with state: UICellConfigurationState) {
        super.update(with: state)

        textView.textView.isUserInteractionEnabled = state.isEditing
    }

    // MARK: - Setup views
    
    private func setupLayout() {
        contentStackView.addArrangedSubview(TextBlockIconView(viewType: .empty))
        contentStackView.addArrangedSubview(textView)

        contentView.addSubview(contentStackView) {
            topContentConstraint = $0.top.equal(to: contentView.topAnchor)
            bottomContentnConstraint = $0.bottom.equal(to: contentView.bottomAnchor)
            $0.leading.equal(to: contentView.leadingAnchor)
            $0.trailing.equal(to: contentView.trailingAnchor)
        }

        backgroundColorView.addSubview(contentView) {
            $0.pinToSuperview(insets: TextBlockLayout.contentInset)
        }

        createEmptyBlockButton.layoutUsing.anchors {
            $0.height.equal(to: 26)
        }

        mainStackView.addArrangedSubview(backgroundColorView)
        mainStackView.addArrangedSubview(createEmptyBlockButton)

        addSubview(mainStackView) {
            topMainConstraint = $0.top.equal(to: topAnchor)
            bottomMainConstraint = $0.bottom.equal(to: bottomAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
    }

    // MARK: - Apply configuration
    
    private func applyNewConfiguration() {
        textView.textView.textStorage.setAttributedString(currentConfiguration.text.attrString)
        
        let restrictions = BlockRestrictionsBuilder.build(textContentType: currentConfiguration.content.contentType)
        
        TextBlockLeftViewStyler.applyStyle(contentStackView: contentStackView, configuration: currentConfiguration)
        TextBlockTextViewStyler.applyStyle(textView: textView, configuration: currentConfiguration, restrictions: restrictions)

        updateAllConstraint(blockTextStyle: currentConfiguration.content.contentType)
        
        textView.delegate = self
        
        let displayPlaceholder = currentConfiguration.content.contentType == .toggle && currentConfiguration.shouldDisplayPlaceholder
        createEmptyBlockButton.isHidden = !displayPlaceholder

        backgroundColorView.backgroundColor = currentConfiguration.information.backgroundColor.map { UIColor.Background.uiColor(from: $0) }

        focusSubscription = currentConfiguration.focusPublisher.sink { [weak self] focus in
            self?.textView.setFocus(focus)
        }
    }
    
    private func updateAllConstraint(blockTextStyle: BlockText.Style) {
        let mainInset = TextBlockLayout.mainInset(textBlockStyle: blockTextStyle)
        let contentInset = TextBlockLayout.contentInset(textBlockStyle: blockTextStyle)
        
        topMainConstraint?.constant = mainInset.top
        bottomMainConstraint?.constant = mainInset.bottom
        
        topContentConstraint?.constant = contentInset.top
        bottomContentnConstraint?.constant = contentInset.bottom
    }
    
}

private extension TextBlockContentView {
    
    static func makeMainStackView() -> UIStackView {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
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
