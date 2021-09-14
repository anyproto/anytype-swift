import UIKit
import Combine
import BlocksModels


final class TextBlockContentView: UIView & UIContentView {
    private(set) var currentConfiguration: TextBlockContentConfiguration
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let configuration = newValue as? TextBlockContentConfiguration else { return }
            guard configuration != currentConfiguration else { return }
            
            currentConfiguration = configuration
            applyNewConfiguration()
        }
    }

    private var focusSubscription: AnyCancellable?
    private(set) var accessoryViewSwitcher: AccessoryViewSwitcherProtocol?

    init(configuration: TextBlockContentConfiguration) {
        self.currentConfiguration = configuration

        super.init(frame: .zero)

        self.accessoryViewSwitcher = configuration
            .accessoryViewBuilder
            .accessoryViewSwitcher()
        setupLayout()
        applyNewConfiguration()
    }

    // MARK: - Setup views
    var topMainConstraint: NSLayoutConstraint?
    var bottomMainConstraint: NSLayoutConstraint?
    var topContentConstraint: NSLayoutConstraint?
    var bottomContentnConstraint: NSLayoutConstraint?

    private func setupLayout() {
        addSubview(mainStackView) {
            topMainConstraint = $0.top.equal(to: topAnchor)
            bottomMainConstraint = $0.bottom.equal(to: bottomAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
        backgroundColorView.addSubview(contentView) {
            $0.pinToSuperview(insets: TextBlockLayout.contentInset)
        }
        backgroundColorView.addSubview(selectionView) {
            $0.pinToSuperview(insets: TextBlockLayout.selectionViewInset)
        }
        
        mainStackView.addArrangedSubview(backgroundColorView)
        mainStackView.addArrangedSubview(createEmptyBlockButton)

        createEmptyBlockButton.heightAnchor.constraint(equalToConstant: 26).isActive = true

        contentView.addSubview(contentStackView) {
            topContentConstraint = $0.top.equal(to: contentView.topAnchor)
            bottomContentnConstraint = $0.bottom.equal(to: contentView.bottomAnchor)
            $0.leading.equal(to: contentView.leadingAnchor)
            $0.trailing.equal(to: contentView.trailingAnchor)
        }

        contentStackView.addArrangedSubview(TextBlockIconView(viewType: .empty))
        contentStackView.addArrangedSubview(textView)
    }

    private func updateAllConstraint(blockTextStyle: BlockText.Style) {
        var mainInset = TextBlockLayout.mainInset(textBlockStyle: blockTextStyle)
        let contentInset = TextBlockLayout.contentInset(textBlockStyle: blockTextStyle)

        // Update top indentaion if current block not in the header and upper block is in the header block
        if currentConfiguration.block.parent?.information.content.type != .layout(.header),
           currentConfiguration.upperBlock?.parent?.information.content.type == .layout(.header) {
            mainInset = TextBlockLayout.mainInsetForBlockAfterHeader
        }
        topMainConstraint?.constant = mainInset.top
        bottomMainConstraint?.constant = mainInset.bottom
        topContentConstraint?.constant = contentInset.top
        bottomContentnConstraint?.constant = contentInset.bottom
    }

    // MARK: - Apply configuration
    private func applyNewConfiguration() {
        let restrictions = BlockRestrictionsFactory().makeTextRestrictions(for: currentConfiguration.content.contentType)
        
        TextBlockLeftViewStyler.applyStyle(contentStackView: contentStackView, configuration: currentConfiguration)
        TextBlockTextViewStyler.applyStyle(textView: textView, configuration: currentConfiguration, restrictions: restrictions)

        updateAllConstraint(blockTextStyle: currentConfiguration.content.contentType)

        textView.delegate = self
        
        textView.textView.textStorage.setAttributedString(currentConfiguration.text.attrString)
        
        let displayPlaceholder = currentConfiguration.content.contentType == .toggle && currentConfiguration.shouldDisplayPlaceholder
        createEmptyBlockButton.isHidden = !displayPlaceholder

        backgroundColorView.backgroundColor = currentConfiguration.information.backgroundColor?.color(background: true)
        selectionView.updateStyle(isSelected: currentConfiguration.isSelected)
        
        focusSubscription = currentConfiguration.focusPublisher.sink { [weak self] focus in
            self?.textView.setFocus(focus)
        }
    }

    // MARK: - Views
    private let backgroundColorView = UIView()
    private let selectionView = TextBlockSelectionView()
    private let contentView = UIView()
    private(set) lazy var textView = CustomTextView()
    private(set) lazy var createEmptyBlockButton = EmptyToggleButtonBuilder.create { [weak self] in
        guard let self = self else { return }
        let blockId = self.currentConfiguration.information.id
        self.currentConfiguration.actionHandler.handleAction(
            .createEmptyBlock(parentId: blockId), blockId: blockId
        )
    }
    
    private let mainStackView: UIStackView = {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        return mainStackView
    }()
    
    private let contentStackView: UIStackView = {
        let contentStackView = UIStackView()
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fill
        contentStackView.spacing = 4
        contentStackView.alignment = .top
        return contentStackView
    }()
    
    // MARK: - Unavailable
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
