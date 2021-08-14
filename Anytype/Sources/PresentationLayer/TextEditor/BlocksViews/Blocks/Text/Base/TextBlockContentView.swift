import UIKit
import Combine
import BlocksModels


final class TextBlockContentView: UIView & UIContentView {
    // MARK: Views
    private let backgroundColorView = UIView()
    private let selectionView = UIView()
    
    private(set) lazy var textView: CustomTextView = .init()
    private(set) lazy var createEmptyBlockButton = buildCreateEmptyBlockButton()
    private var accessoryViewSwitcher: AccessoryViewSwitcher?
    
    private let mainStackView: UIStackView = {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        return mainStackView
    }()
    
    private let topStackView: UIStackView = {
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

    private func setupLayout() {
        addSubview(backgroundColorView) {
            $0.pinToSuperview(insets: LayoutConstants.backgroundViewInsets)
        }
        addSubview(mainStackView) {
            $0.pinToSuperview(insets: LayoutConstants.insets)
        }
        addSubview(selectionView) {
            $0.pinToSuperview(insets: LayoutConstants.selectionViewInsets)
        }
        
        mainStackView.addArrangedSubview(topStackView)
        mainStackView.addArrangedSubview(createEmptyBlockButton)
        
        createEmptyBlockButton.heightAnchor.constraint(equalToConstant: 26).isActive = true

        topStackView.addArrangedSubview(TextBlockIconView(viewType: .empty))
        topStackView.addArrangedSubview(textView)
    }

    // MARK: - Apply configuration

    private func apply(configuration: TextBlockContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        
        currentConfiguration = configuration
        applyNewConfiguration()
    }

    private func applyNewConfiguration() {
        // reset content cell to plain text
        replaceCurrentLeftView(with: TextBlockIconView(viewType: .empty))
        setupText(placeholer: "", font: .body)
        topStackView.spacing = 4
        
        subscriptions.removeAll()
        textView.delegate = self
        let restrictions = BlockRestrictionsFactory().makeRestrictions(
            for: currentConfiguration.information.content.type
        )
        updateAccessoryView(restrictions: restrictions)
        updatePartialTextSelectionMenuItems(restrictions: restrictions)

        let autocorrect = currentConfiguration.information.content.type == .text(.title) ? false : true
        let options = CustomTextViewOptions(
            createNewBlockOnEnter: restrictions.canCreateBlockBelowOnEnter,
            autocorrect: autocorrect
        )
        textView.setCustomTextViewOptions(options: options)

        guard case let .text(text) = self.currentConfiguration.block.information.content else { return }
        // In case of configurations is not equal we should check what exactly we should change
        // Because configurations for checkbox block and numbered block may not be equal, so we must rebuld whole view
        createEmptyBlockButton.isHidden = true
        textView.textView.selectedColor = nil

        switch text.contentType {
        case .title:
            setupTitle(text)
        case .description:
            setupText(placeholer: "Add a description".localized, font: .body)
        case .text:
            setupText(placeholer: "", font: .body)
        case .toggle:
            setupForToggle()
        case .bulleted:
            setupForBulleted()
        case .checkbox:
            setupForCheckbox(checked: text.checked)
        case .numbered:
            setupForNumbered(number: text.number)
        case .quote:
            setupForQuote()
        case .header:
            setupText(placeholer: "Title".localized, font: .heading)
        case .header2:
            setupText(placeholer: "Heading".localized, font: .subheading)
        case .header3:
            setupText(placeholer: "Subheading".localized, font: .headlineSemibold)
        case .header4, .code:
            break
        }

        currentConfiguration.focusPublisher.sink { [weak self] focus in
            self?.textView.setFocus(focus)
        }.store(in: &subscriptions)

        let cursorPosition = textView.textView.selectedRange
        let string = NSMutableAttributedString(attributedString: text.attributedText)
        if string != textView.textView.textStorage {
            textView.textView.textStorage.setAttributedString(string)
        }
        textView.textView.tertiaryColor = text.color?.color(background: false)
        textView.textView.textAlignment = currentConfiguration.information.alignment.asNSTextAlignment
        textView.textView.selectedRange = cursorPosition

        backgroundColorView.backgroundColor = currentConfiguration.information.backgroundColor?.color(background: true)

        selectionView.layer.borderWidth = 0.0
        selectionView.layer.borderColor = nil
        selectionView.backgroundColor = .clear

        if currentConfiguration.isSelected {
            selectionView.layer.borderWidth = 2.0
            selectionView.layer.borderColor = UIColor.pureAmber.cgColor
            selectionView.backgroundColor = UIColor.pureAmber.withAlphaComponent(0.1)
        }
    }
    
    private func setupTitle(_ blockText: BlockText) {
        setupText(placeholer: "Untitled".localized, font: .title)
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
            topStackView.spacing = 8
            textView.textView.textContainerInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
        }
    }
    
    private func setupText(placeholer: String, font: UIFont) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.secondaryTextColor
        ]

        textView.textView.update(placeholder: .init(string: placeholer, attributes: attributes))
        textView.textView.font = font
        textView.textView.typingAttributes = [.font: font]
        textView.textView.defaultFontColor = .textColor
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
        setupText(placeholer: "Checkbox".localized, font: .body)
        // selected color
        textView.textView.selectedColor = checked ? UIColor.secondaryTextColor : nil
    }
    
    private func setupForBulleted() {
        let leftView = TextBlockIconView(viewType: .bulleted)
        replaceCurrentLeftView(with: leftView)
        setupText(placeholer: "Bulleted placeholder".localized, font: .body)
    }
    
    private func setupForNumbered(number: Int) {
        let leftView = TextBlockIconView(viewType: .numbered(number))
        replaceCurrentLeftView(with: leftView)
        setupText(placeholer: "Numbered placeholder".localized, font: .body)
    }
    
    private func setupForQuote() {
        setupText(placeholer: "Quote".localized, font: .headline)
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
        setupText(placeholer: "Toggle block".localized, font: .body)
        createEmptyBlockButton.isHidden = !currentConfiguration.shouldDisplayPlaceholder
    }
    
    private func replaceCurrentLeftView(with leftView: UIView) {
        topStackView.arrangedSubviews.first?.removeFromSuperview()
        topStackView.insertArrangedSubview(leftView, at: 0)
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
                    .font: UIFont.body,
                    .foregroundColor: UIColor.secondaryTextColor
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
        let allAttributes = BlockHandlerActionType.TextAttributesType.allCases
        let availableAttributes = allAttributes.filter { attribute -> Bool in
            switch attribute {
            case .bold:
                return restrictions.canApplyBold
            case .italic:
                return restrictions.canApplyItalic
            case .strikethrough, .keyboard:
                return restrictions.canApplyOtherMarkup
            }
        }
        textView.textView.availableTextAttributes = availableAttributes
    }
    
    private enum LayoutConstants {
        static let insets: UIEdgeInsets = .init(top: 1, left: 20, bottom: -1, right: -20)
        static let backgroundViewInsets: UIEdgeInsets = .init(top: 1, left: 0, bottom: -1, right: 0)
        static let selectionViewInsets: UIEdgeInsets = .init(top: 1, left: 8, bottom: -1, right: -8)
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

        let accessoryViewSwitcher = AccessoryViewSwitcher(textView: textView.textView,
                                                          delegate: self,
                                                          mentionsView: mentionsView,
                                                          accessoryView: accessoryView)
        textView.setAccessoryViewSwitcher(accessoryViewSwitcher: accessoryViewSwitcher)
        mentionsView.delegate = accessoryViewSwitcher
        editorAccessoryhandler.customTextView = textView
        editorAccessoryhandler.switcher = accessoryViewSwitcher
        self.accessoryViewSwitcher = accessoryViewSwitcher
    }

    private func updateAccessoryView(restrictions: BlockRestrictions) {
        if currentConfiguration.information.content.type == .text(.title) {
            accessoryViewSwitcher?.editingView.updateMenuItems([.style, .mention])
        } else {
            accessoryViewSwitcher?.editingView.updateMenuItems([.slash, .style, .mention])
        }

        // don't show slash menu for title
        if currentConfiguration.information.content.type != .text(.title) {
            let items = BlockActionsBuilder(restrictions: restrictions).makeBlockActionsMenuItems()

            if accessoryViewSwitcher?.slashMenuView == nil {
                let actionsHandler = SlashMenuActionsHandlerImp(
                    blockActionHandler: currentConfiguration.actionHandler
                )

                let slashMenuView = SlashMenuView(
                    frame: CGRect(origin: .zero, size: LayoutConstants.menuActionsViewSize),
                    menuItems: items,
                    slashMenuActionsHandler: actionsHandler
                )
                accessoryViewSwitcher?.slashMenuView = slashMenuView
            } else {
                accessoryViewSwitcher?.slashMenuView?.menuItems = items
            }
        } else {
            accessoryViewSwitcher?.slashMenuView = nil
        }
    }
}

// MARK: - TextBlockAccessoryViewSwitcherDeleagte

extension TextBlockContentView: TextBlockAccessoryViewSwitcherDeleagte {
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
}
