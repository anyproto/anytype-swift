import UIKit
import Combine
import BlocksModels


final class TextBlockContentView: UIView & UIContentView {
    // MARK: Views
    private let backgroundColorView = UIView()
    private let selectionView = UIView()
    private let contentView = UIView()
    
    private(set) lazy var textView: CustomTextView = .init()
    private(set) lazy var createEmptyBlockButton = buildCreateEmptyBlockButton()
    private(set) var accessoryViewSwitcher: AccessoryViewSwitcher?
    
    private let mainStackView: UIStackView = {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        return mainStackView
    }()
    
    private let contentStackView: UIStackView = {
        let topStackView = UIStackView()
        topStackView.axis = .horizontal
        topStackView.distribution = .fill
        topStackView.spacing = 4
        topStackView.alignment = .top
        return topStackView
    }()

    // MARK: Configuration

    private(set) var currentConfiguration: TextBlockContentConfiguration
    
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let configuration = newValue as? TextBlockContentConfiguration else { return }
            
            apply(configuration: configuration)
        }
    }

    // Combine Subscriptions
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Initialization

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(configuration: TextBlockContentConfiguration) {
        self.currentConfiguration = configuration

        super.init(frame: .zero)

        buildAccessoryViews()
        setupViews()
        applyNewConfiguration()
    }

    // MARK: - Setup views

    private func setupViews() {
        selectionView.layer.cornerRadius = 6
        selectionView.layer.cornerCurve = .continuous
        selectionView.isUserInteractionEnabled = false
        selectionView.clipsToBounds = true

        setupLayout()
    }

    var topMainConstraint: NSLayoutConstraint?
    var bottomMainConstraint: NSLayoutConstraint?
    var topContetnConstraint: NSLayoutConstraint?
    var bottomContentnConstraint: NSLayoutConstraint?

    private func setupLayout() {
        addSubview(mainStackView) {
            topMainConstraint = $0.top.equal(to: topAnchor)
            bottomMainConstraint = $0.bottom.equal(to: bottomAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
        backgroundColorView.addSubview(contentView) {
            $0.pinToSuperview(insets: LayoutConstants.contentInset)
        }
        backgroundColorView.addSubview(selectionView) {
            $0.pinToSuperview(insets: LayoutConstants.selectionViewInset)
        }
        
        mainStackView.addArrangedSubview(backgroundColorView)
        mainStackView.addArrangedSubview(createEmptyBlockButton)

        createEmptyBlockButton.heightAnchor.constraint(equalToConstant: 26).isActive = true

        contentView.addSubview(contentStackView) {
            topContetnConstraint = $0.top.equal(to: contentView.topAnchor)
            bottomContentnConstraint = $0.bottom.equal(to: contentView.bottomAnchor)
            $0.leading.equal(to: contentView.leadingAnchor)
            $0.trailing.equal(to: contentView.trailingAnchor)
        }

        contentStackView.addArrangedSubview(TextBlockIconView(viewType: .empty))
        contentStackView.addArrangedSubview(textView)
    }

    private func updateAllConstraint(blockTextStyle: BlockText.Style) {
        var mainInset = LayoutConstants.mainInset(textBlockStyle: blockTextStyle)
        let contentInset = LayoutConstants.contentInset(textBlockStyle: blockTextStyle)

        // Update top indentaion if current block not in the header and upper block is in the header block
        if currentConfiguration.block.parent?.information.content.type != .layout(.header),
           currentConfiguration.upperBlock?.parent?.information.content.type == .layout(.header) {
            mainInset = LayoutConstants.mainInsetForBlockAfterHeader

        }
        topMainConstraint?.constant = mainInset.top
        bottomMainConstraint?.constant = mainInset.bottom
        topContetnConstraint?.constant = contentInset.top
        bottomContentnConstraint?.constant = contentInset.bottom
    }

    // MARK: - Apply configuration

    private func apply(configuration: TextBlockContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        
        currentConfiguration = configuration
        applyNewConfiguration()
    }

    private func applyNewConfiguration() {
        guard case let .text(text) = self.currentConfiguration.block.information.content else { return }

        textView.textView.textContainerInset = .zero

        // reset content cell to plain text
        replaceCurrentLeftView(with: TextBlockIconView(viewType: .empty))
        setupText(placeholer: "", textStyle: .bodyRegular)
        contentStackView.spacing = 4

        updateAllConstraint(blockTextStyle: text.contentType)

        // reset subscriptions
        subscriptions.removeAll()
        // update text view delegate
        textView.delegate = self

        // set text view options
        let restrictions = BlockRestrictionsFactory().makeRestrictions(
            for: currentConfiguration.information.content.type
        )
        accessoryViewSwitcher?.updateBlockType(with: currentConfiguration.information.content.type)
        updatePartialTextSelectionMenuItems(restrictions: restrictions)

        let autocorrect = currentConfiguration.information.content.type == .text(.title) ? false : true
        let options = CustomTextViewOptions(
            createNewBlockOnEnter: restrictions.canCreateBlockBelowOnEnter,
            autocorrect: autocorrect
        )
        textView.setCustomTextViewOptions(options: options)

        // In case of configurations is not equal we should check what exactly we should change
        // Because configurations for checkbox block and numbered block may not be equal, so we must rebuld whole view
        createEmptyBlockButton.isHidden = true
        textView.textView.selectedColor = nil

        // setup attr text
        let string = NSMutableAttributedString(attributedString: text.attributedText)
        if string != textView.textView.textStorage {
            textView.textView.textStorage.setAttributedString(string)
        }

        switch text.contentType {
        case .title:
            setupTitle(text)
            setupLineHeight(textStyle: .title)
        case .description:
            setupText(placeholer: "Add a description".localized, textStyle: .relation2Regular)
            setupLineHeight(textStyle: .relation2Regular)
        case .text:
            setupText(placeholer: "", textStyle: .bodyRegular)
            setupLineHeight(textStyle: .bodyRegular)
        case .toggle:
            setupForToggle()
            setupLineHeight(textStyle: .bodyRegular)
        case .bulleted:
            setupForBulleted()
            setupLineHeight(textStyle: .bodyRegular)
        case .checkbox:
            setupForCheckbox(checked: text.checked)
            setupLineHeight(textStyle: .bodyRegular)
        case .numbered:
            setupForNumbered(number: text.number)
            setupLineHeight(textStyle: .bodyRegular)
        case .quote:
            setupForQuote()
            setupLineHeight(textStyle: .bodyRegular)
        case .header:
            setupText(placeholer: "Title".localized, textStyle: .title)
            setupLineHeight(textStyle: .title)
        case .header2:
            setupText(placeholer: "Heading".localized, textStyle: .heading)
            setupLineHeight(textStyle: .heading)
        case .header3:
            setupText(placeholer: "Subheading".localized, textStyle: .subheading)
            setupLineHeight(textStyle: .subheading)
        case .header4, .code:
            break
        }

        // Confing focus publisher
        currentConfiguration.focusPublisher.sink { [weak self] focus in
            self?.textView.setFocus(focus)
        }.store(in: &subscriptions)

        // Config content background color
        textView.textView.tertiaryColor = text.color?.color(background: false)
        // Config content text alingment
        textView.textView.textAlignment = currentConfiguration.information.alignment.asNSTextAlignment
        // Config cursorPosition
        let cursorPosition = textView.textView.selectedRange
        textView.textView.selectedRange = cursorPosition
        // Config background color
        backgroundColorView.backgroundColor = currentConfiguration.information.backgroundColor?.color(background: true)

        // Config selection view
        selectionView.layer.borderWidth = 0.0
        selectionView.layer.borderColor = nil
        selectionView.backgroundColor = .clear

        if currentConfiguration.isSelected {
            selectionView.layer.borderWidth = 2.0
            selectionView.layer.borderColor = UIColor.pureAmber.cgColor
            selectionView.backgroundColor = UIColor.pureAmber.withAlphaComponent(0.1)
        }
    }

    // Setup line height
    private func setupLineHeight(textStyle: AnytypeFontBuilder.TextStyle) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = AnytypeFontBuilder.lineSpacing(textStyle)

        let range = NSMakeRange(0, textView.textView.textStorage.length)
        textView.textView.textStorage.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)

        let topBottomTextSpacing = AnytypeFontBuilder.lineSpacing(textStyle) / 2
        textView.textView.textContainerInset = .init(top: topBottomTextSpacing, left: 0, bottom: topBottomTextSpacing, right: 0)
        textView.textView.typingAttributes = [.paragraphStyle: paragraphStyle]
            .merging(textView.textView.typingAttributes, uniquingKeysWith: { (first, _) in first })
    }

    // MARK: - Setups for different type of text block
    
    private func setupTitle(_ blockText: BlockText) {
        setupText(placeholer: "Untitled".localized, textStyle: .title)

        if currentConfiguration.isCheckable {
            let leftView = TextBlockIconView(viewType: .titleCheckbox(isSelected: blockText.checked)) { [weak self] in
                guard let self = self else { return }
                
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                self.currentConfiguration.actionHandler.handleAction(
                    .checkbox(selected: !blockText.checked),
                    blockId: self.currentConfiguration.information.id
                )
            }
            replaceCurrentLeftView(with: leftView)
            contentStackView.spacing = 8
        }
    }
    
    private func setupText(placeholer: String, textStyle: AnytypeFontBuilder.TextStyle) {
        let font = AnytypeFontBuilder.uiKitFont(textStyle: textStyle)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.textSecondary,
        ]

        textView.textView.update(placeholder: .init(string: placeholer, attributes: attributes))
        textView.textView.font = font
        textView.textView.typingAttributes = [.font: font]
        textView.textView.defaultFontColor = .textPrimary
    }
    
    private func setupForCheckbox(checked: Bool) {
        let leftView = TextBlockIconView(viewType: .checkbox(isSelected: checked)) { [weak self] in
            guard let self = self else { return }
            
            UISelectionFeedbackGenerator().selectionChanged()
            self.currentConfiguration.actionHandler.handleAction(
                .checkbox(selected: !checked),
                blockId: self.currentConfiguration.information.id
            )
        }
        replaceCurrentLeftView(with: leftView)
        setupText(placeholer: "Checkbox".localized, textStyle: .bodyRegular)
        // selected color
        textView.textView.selectedColor = checked ? UIColor.textSecondary : nil
    }
    
    private func setupForBulleted() {
        let leftView = TextBlockIconView(viewType: .bulleted)
        replaceCurrentLeftView(with: leftView)
        setupText(placeholer: "Bulleted placeholder".localized, textStyle: .bodyRegular)
    }
    
    private func setupForNumbered(number: Int) {
        let leftView = TextBlockIconView(viewType: .numbered(number))
        replaceCurrentLeftView(with: leftView)
        setupText(placeholer: "Numbered placeholder".localized, textStyle: .bodyRegular)
    }
    
    private func setupForQuote() {
        setupText(placeholer: "Quote".localized, textStyle: .bodyRegular)
        replaceCurrentLeftView(with: TextBlockIconView(viewType: .quote))
    }
    
    private func setupForToggle() {
        let leftView = TextBlockIconView(
            viewType: .toggle(toggled: currentConfiguration.block.isToggled)) { [weak self] in
            guard let self = self else { return }
            self.currentConfiguration.block.toggle()
            self.currentConfiguration.actionHandler.handleAction(
                .toggle,
                blockId: self.currentConfiguration.information.id
            )
        }
        replaceCurrentLeftView(with: leftView)
        setupText(placeholer: "Toggle block".localized, textStyle: .bodyRegular)
        createEmptyBlockButton.isHidden = !currentConfiguration.shouldDisplayPlaceholder
    }

    // MARK: -
    
    private func replaceCurrentLeftView(with leftView: UIView) {
        contentStackView.arrangedSubviews.first?.removeFromSuperview()
        contentStackView.insertArrangedSubview(leftView, at: 0)
    }
    
    private func buildCreateEmptyBlockButton() -> UIButton {
        let button = UIButton(
            primaryAction: .init(
                handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.currentConfiguration.actionHandler.handleAction(
                        .createEmptyBlock(
                            parentId: self.currentConfiguration.information.id
                        ),
                        blockId: self.currentConfiguration.information.id
                    )
                }
            )
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(
            .init(
                string: "Toggle empty Click and drop block inside".localized,
                attributes: [
                    .font: UIFont.bodyRegular,
                    .foregroundColor: UIColor.textSecondary
                ]
            ),
            for: .normal
        )
        button.contentHorizontalAlignment = .leading
        button.isHidden = true
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }
    
    private func updatePartialTextSelectionMenuItems(restrictions: BlockRestrictions) {
        let allOptions = TextViewContextMenuOption.allCases
        let availableOptions = allOptions.filter { option -> Bool in
            switch option {
            case let .toggleMarkup(type):
                switch type {
                case .bold:
                    return restrictions.canApplyBold
                case .italic:
                    return restrictions.canApplyItalic
                case .strikethrough, .keyboard:
                    return restrictions.canApplyOtherMarkup
                }
            case .setLink:
                return restrictions.canApplyOtherMarkup
            }
        }
        textView.textView.availableContextMenuOptions = availableOptions
    }

    // MARK: - LayoutConstants
    
    private enum LayoutConstants {
        static let contentInset: UIEdgeInsets = .init(top: 0, left: 20, bottom: 0, right: -20)
        static let selectionViewInset: UIEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: -8)

        static func mainInset(textBlockStyle: BlockText.Style) -> NSDirectionalEdgeInsets {
            switch textBlockStyle {
            case .title:
                return .zero
            case .description:
                return .init(top: 8, leading: 0, bottom: 0, trailing: 0)
            case .header:
                return .init(top: 24, leading: 0, bottom: -2, trailing: 0)
            case .header2, .header3:
                return .init(top: 16, leading: 0, bottom: -2, trailing: 0)
            default:
                return .init(top: 0, leading: 0, bottom: -2, trailing: 0)
            }
        }

        static func contentInset(textBlockStyle: BlockText.Style) -> NSDirectionalEdgeInsets {
            switch textBlockStyle {
            case .title:
                return .zero
            case .description:
                return .zero
            case .header:
                return .init(top: 5, leading: 0, bottom: -3, trailing: 0)
            case .header2:
                return .init(top: 5, leading: 0, bottom: -5, trailing: 0)
            default:
                return .init(top: 4, leading: 0, bottom: -4, trailing: 0)
            }
        }

        static let mainInsetForBlockAfterHeader: NSDirectionalEdgeInsets = .init(top: 22, leading: 0, bottom: -2, trailing: 0)

        static let menuActionsViewSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.isFourInch ? 160 : 215
        )
    }
}

// MARK: - Accessory view

extension TextBlockContentView {
    private func buildAccessoryViews() {
        let mentionsView = MentionView(frame: CGRect(origin: .zero, size: LayoutConstants.menuActionsViewSize))
        let editorAccessoryhandler = EditorAccessoryViewActionHandler(delegate: self)
        let accessoryView = EditorAccessoryView(actionHandler: editorAccessoryhandler)
        let actionsHandler = SlashMenuActionsHandlerImp(
            blockActionHandler: currentConfiguration.actionHandler
        )
        let restrictions = BlockRestrictionsFactory().makeRestrictions(
            for: currentConfiguration.information.content.type
        )
        let items = BlockActionsBuilder(restrictions: restrictions).makeBlockActionsMenuItems()
        let slashMenuView = SlashMenuView(
            frame: CGRect(origin: .zero, size: LayoutConstants.menuActionsViewSize),
            menuItems: items,
            slashMenuActionsHandler: actionsHandler
        )

        let accessoryViewSwitcher = AccessoryViewSwitcher(textView: textView.textView,
                                                          delegate: self,
                                                          mentionsView: mentionsView,
                                                          slashMenuView: slashMenuView,
                                                          accessoryView: accessoryView)
        mentionsView.delegate = accessoryViewSwitcher
        editorAccessoryhandler.customTextView = textView
        editorAccessoryhandler.switcher = accessoryViewSwitcher
        self.accessoryViewSwitcher = accessoryViewSwitcher
    }
}

// MARK: - TextBlockAccessoryViewSwitcherDeleagte

extension TextBlockContentView: AccessoryViewSwitcherDelegate {
    func mentionSelected(_ mention: MentionObject, from: UITextPosition, to: UITextPosition) {
        // TODO: Accessory check if no need
//        mentionConfiguration.configure(textView: textView.textView)
        textView.textView.insert(mention, from: from, to: to)

        self.currentConfiguration.actionHandler.handleAction(
            .textView(
                action: .changeText(self.textView.textView.attributedText),
                block: self.currentConfiguration.block
            ),
            blockId: self.currentConfiguration.information.id
        )
    }
    
    func didEnterURL(_ url: URL?) {
        let range = textView.textView.selectedRange
        currentConfiguration.actionHandler.handleAction(
            .setLink(url, range),
            blockId: currentConfiguration.information.id
        )
    }
}
