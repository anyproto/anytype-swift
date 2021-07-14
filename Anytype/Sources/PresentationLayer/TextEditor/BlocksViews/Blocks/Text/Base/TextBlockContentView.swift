
import UIKit
import Combine
import BlocksModels


// MARK: - TextBlockContentView

final class TextBlockContentView: UIView & UIContentView {
    // MARK: Constants
    private enum LayoutConstants {
        static let insets: UIEdgeInsets = .init(top: 1, left: 20, bottom: -1, right: -20)
        static let backgroundViewInsets: UIEdgeInsets = .init(top: 1, left: 0, bottom: -1, right: 0)
        static let selectionViewInsets: UIEdgeInsets = .init(top: 1, left: 8, bottom: -1, right: -8)
    }

    private enum Constants {
        enum Toggle {
            static let titleEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0)
        }
    }

    // MARK: Views
    private let backgroundColorView = UIView()
    private let selectionView = UIView()

    private(set) lazy var textView: CustomTextView = {
        let actionsHandler = SlashMenuActionsHandlerImp(
            blockActionHandler: currentConfiguration.blockActionHandler
        )
        
        let restrictions = BlockRestrictionsFactory().makeRestrictions(
            for: currentConfiguration.information.content.type
        )
        
        let mentionsSelectionHandler = { [weak self] (mention: MentionObject) in
            guard let self = self,
                  let mentionSymbolPosition = self.textView.inputSwitcher.accessoryViewTriggerSymbolPosition,
                  let previousToMentionSymbol = self.textView.textView.position(from: mentionSymbolPosition,
                                                                                offset: -1),
                  let caretPosition = self.textView.textView.caretPosition(),
                  let viewModel = self.currentConfiguration.viewModel else { return }

            self.textView.textView.insert(mention, from: previousToMentionSymbol, to: caretPosition)
            self.currentConfiguration.setupMentionsInteraction(self.textView)

            viewModel.actionHandler.handleAction(
                .textView(
                    action: .changeText(self.textView.textView.attributedText),
                    activeRecord: viewModel.block
                ),
                info: viewModel.block.blockModel.information
            )
        }
        
        let autocorrect = currentConfiguration.information.content.type == .text(.title) ? false : true
        let options = CustomTextView.Options(
            createNewBlockOnEnter: restrictions.canCreateBlockBelowOnEnter,
            autocorrect: autocorrect
        )

        let blockActionBuilder = BlockActionsBuilder(restrictions: restrictions)
        return CustomTextView(
            options: options,
            menuItemsBuilder: blockActionBuilder,
            slashMenuActionsHandler: actionsHandler,
            mentionsSelectionHandler: mentionsSelectionHandler
        )
    }()

    private lazy var createChildBlockButton: UIButton = {
        let button: UIButton = .init(primaryAction: .init(handler: { [weak self] _ in
            guard let self = self,
                  let block = self.currentConfiguration.viewModel?.block else { return }
            self.currentConfiguration.viewModel?.actionHandler.handleAction(
                .createEmptyBlock(parentId: block.blockModel.information.id),
                info: block.blockModel.information
            )
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(.init(string: NSLocalizedString("Toggle empty Click and drop block inside",
                                                                  comment: ""),
                                        attributes: [.font: UIFont.bodyFont,
                                                     .foregroundColor: UIColor.secondaryTextColor]),
                                  for: .normal)
        button.contentHorizontalAlignment = .leading
        button.isHidden = true
        button.titleEdgeInsets = Constants.Toggle.titleEdgeInsets
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()

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

    private var currentConfiguration: TextBlockContentConfiguration

    var configuration: UIContentConfiguration {
        get { self.currentConfiguration }
        set {
            guard let configuration = newValue as? TextBlockContentConfiguration else { return }
            self.apply(configuration: configuration)
        }
    }

    // Combine Subscriptions
    private var subscriptions: Set<AnyCancellable> = .init()

    // MARK: - Initialization

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(configuration: TextBlockContentConfiguration) {
        self.currentConfiguration = configuration

        super.init(frame: .zero)

        self.setupViews()
        self.applyNewConfiguration()
    }

    // MARK: - Setup views

    private func setupViews() {
        addSubview(backgroundColorView)
        addSubview(mainStackView)
        addSubview(selectionView)

        mainStackView.addArrangedSubview(topStackView)
        mainStackView.addArrangedSubview(createChildBlockButton)

        topStackView.addArrangedSubview(TextBlockIconView(viewType: .empty))
        topStackView.addArrangedSubview(textView)

        selectionView.layer.cornerRadius = 6
        selectionView.layer.cornerCurve = .continuous
        selectionView.isUserInteractionEnabled = false
        selectionView.clipsToBounds = true

        self.setupLayout()
    }

    private func setupLayout() {
        createChildBlockButton.heightAnchor.constraint(equalToConstant: 26.5).isActive = true

        mainStackView.pinAllEdges(to: self, insets: LayoutConstants.insets)
        backgroundColorView.pinAllEdges(to: self, insets: LayoutConstants.backgroundViewInsets)
        selectionView.pinAllEdges(to: self, insets: LayoutConstants.selectionViewInsets)
    }

    // MARK: - Apply configuration

    private func apply(configuration: TextBlockContentConfiguration) {
        guard self.currentConfiguration != configuration else { return }
        self.currentConfiguration = configuration
        self.applyNewConfiguration()
    }

    private func applyNewConfiguration() {
        // reset content cell to plain text
        replaceCurrentLeftView(with: TextBlockIconView(viewType: .empty))
        setupForText()
        subscriptions.removeAll()

        textView.delegate = nil
        // We don't want to handle delegate methods after 'attributedText = nil' it cause side effects
        textView.textView.delegate = nil
        // it's important to clean old attributed string
        textView.textView.attributedText = nil
        textView.textView.delegate = textView
        textView.delegate = currentConfiguration.textViewDelegate
        textView.userInteractionDelegate = currentConfiguration.viewModel

        guard case let .text(text) = self.currentConfiguration.information.content else { return }
        // In case of configurations is not equal we should check what exactly we should change
        // Because configurations for checkbox block and numbered block may not be equal, so we must rebuld whole view
        createChildBlockButton.isHidden = true
        textView.textView.selectedColor = nil

        switch text.contentType {
        case .title:
            self.setupForTitle()
        case .text:
            self.setupForText()
        case .toggle:
            setupForToggle()
        case .bulleted:
            self.setupForBulleted()
        case .checkbox:
            self.setupForCheckbox(checked: text.checked)
        case .numbered:
            self.setupForNumbered(number: text.number)
        case .quote:
            self.setupForQuote()
        case .header:
            self.setupForHeader1()
        case .header2:
            self.setupForHeader2()
        case .header3:
            self.setupForHeader3()
        case .header4, .code:
            break
        }

        currentConfiguration.viewModel?.setFocus.sink { [weak self] focus in
            self?.textView.setFocus(focus)
        }.store(in: &subscriptions)

        currentConfiguration.viewModel?.shouldResignFirstResponder.sink { [weak self] _ in
            self?.textView.shouldResignFirstResponder()
        }.store(in: &subscriptions)

        currentConfiguration.viewModel?.textUpdatePublisher.sink { [weak self] textUpdate in
            guard let self = self else { return }
            let cursorPosition = self.textView.textView.selectedRange
            self.textView.apply(update: textUpdate)
            self.textView.textView.selectedRange = cursorPosition
        }.store(in: &subscriptions)
        
        let update = currentConfiguration.viewModel?.makeTextViewUpdate()
        textView.textView.attributedText = update?.attributedString

        backgroundColorView.backgroundColor = currentConfiguration.information.backgroundColor?.color(background: true)

        selectionView.layer.borderWidth = 0.0
        selectionView.layer.borderColor = nil
        selectionView.backgroundColor = .clear

        if currentConfiguration.isSelected {
            selectionView.layer.borderWidth = 2.0
            selectionView.layer.borderColor = UIColor.pureAmber.cgColor
            selectionView.backgroundColor = UIColor.pureAmber.withAlphaComponent(0.1)
        }
        currentConfiguration.mentionsConfigurator.configure(textView: textView.textView)
    }
    
    private func setupForText() {
        self.setupText(placeholer: "", font: .bodyFont)
    }
    
    private func setupForTitle() {
        self.setupText(placeholer: NSLocalizedString("Title", comment: ""), font: .titleFont)
    }
    
    private func setupForHeader1() {
        self.setupText(placeholer: NSLocalizedString("Header 1", comment: ""), font: .header1Font)
    }
    
    private func setupForHeader2() {
        self.setupText(placeholer: NSLocalizedString("Header 2", comment: ""), font: .header2Font)
    }
    
    private func setupForHeader3() {
        self.setupText(placeholer: NSLocalizedString("Header 3", comment: ""), font: .header3Font)
    }
    
    private func setupText(placeholer: String, font: UIFont) {
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor: UIColor.secondaryTextColor]

        self.textView.textView.update(placeholder: .init(string: placeholer, attributes: attributes))
        self.textView.textView.font = font
        self.textView.textView.typingAttributes = [.font: font]
        self.textView.textView.defaultFontColor = .textColor
    }
    
    private func setupForCheckbox(checked: Bool) {
        let leftView = TextBlockIconView(viewType: .checkbox(isSelected: checked)) { [weak self] in
            self?.currentConfiguration.viewModel?.onCheckboxTap(selected: !checked)
        }
        replaceCurrentLeftView(with: leftView)
        setupText(placeholer: NSLocalizedString("Checkbox placeholder", comment: ""), font: .bodyFont)
        // selected color
        textView.textView.selectedColor = checked ? UIColor.secondaryTextColor : nil
    }
    
    private func setupForBulleted() {
        let leftView = TextBlockIconView(viewType: .bulleted)
        replaceCurrentLeftView(with: leftView)
        setupText(placeholer: NSLocalizedString("Bulleted placeholder", comment: ""), font: .bodyFont)
    }
    
    private func setupForNumbered(number: Int) {
        let leftView = TextBlockIconView(viewType: .numbered(number))
        replaceCurrentLeftView(with: leftView)
        setupText(placeholer: NSLocalizedString("Numbered placeholder", comment: ""), font: .bodyFont)
    }
    
    private func setupForQuote() {
        self.setupText(placeholer: NSLocalizedString("Quote placeholder", comment: ""), font: .highlightFont)
        replaceCurrentLeftView(with: TextBlockIconView(viewType: .quote))
    }
    
    private func setupForToggle() {
        guard let blockViewModel = currentConfiguration.viewModel else { return }

        let leftView = TextBlockIconView(viewType: .toggle(toggled: blockViewModel.block.isToggled)) {
            blockViewModel.block.toggle()
            let toggled = blockViewModel.block.isToggled
            blockViewModel.onToggleTap(toggled: toggled)
        }
        replaceCurrentLeftView(with: leftView)
        setupText(placeholer: NSLocalizedString("Toggle placeholder", comment: ""), font: .bodyFont)
        createChildBlockButton.isHidden = !currentConfiguration.shouldDisplayPlaceholder
    }
    
    private func replaceCurrentLeftView(with leftView: UIView) {
        topStackView.arrangedSubviews.first?.removeFromSuperview()
        topStackView.insertArrangedSubview(leftView, at: 0)
    }
}
