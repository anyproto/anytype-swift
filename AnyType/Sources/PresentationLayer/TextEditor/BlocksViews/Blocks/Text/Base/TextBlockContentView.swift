
import UIKit
import Combine
import BlocksModels


// MARK: - TextBlockContentView

final class TextBlockContentView: UIView & UIContentView {
    struct Layout {
        let insets: UIEdgeInsets = .init(top: 1, left: 20, bottom: -1, right: -20)
    }
    
    private enum Constants {
        enum Text {
            static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
        }
        
        enum Quote {
            static let viewWidth: CGFloat = 14
            static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 14, bottom: 4, right: 8)
        }
        
        enum Bulleted {
            static let viewSide: CGFloat = 28
            static let dotTopOffset: CGFloat = 11
            static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 0, bottom: 4, right: 8)
            static let dotImageName: String = "TextEditor/Style/Text/Bulleted/Bullet"
        }
        
        enum Checkbox {
            static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 8)
            static let checkedImageName: String = "TextEditor/Style/Text/Checkbox/checked"
            static let uncheckedImageName: String = "TextEditor/Style/Text/Checkbox/unchecked"
            static let buttonTag = 1
            static let buttonTopOffset: CGFloat = 2
        }
        
        enum Numbered {
            static let labelTopOffset: CGFloat = 5
            static let leadingViewWidth: CGFloat = 27
            static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 1, bottom: 4, right: 8)
            static let numberToPlaceTextLeft: Int = 20
        }
        
        enum Toggle {
            static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 8)
            static let foldedImageName = "TextEditor/Style/Text/Toggle/folded"
            static let unfoldedImageName = "TextEditor/Style/Text/Toggle/unfolded"
            static let buttonTag = 2
            static let titleEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0)
            static let desiredCreateChildButtonHeight: CGFloat = 26.5
        }
    }
    /// Views
    private let topView = TopWithChildUIKitView()
    private let textView = BlockTextView()

    private lazy var createChildBlockButton: UIButton = {
        let button: UIButton = .init(primaryAction: .init(handler: { [weak self] _ in
            guard let self = self else { return }

            let block = self.currentConfiguration.viewModel.getBlock()
            self.createChildBlockButton.isHidden = true
            self.currentConfiguration.viewModel.send(actionsPayload: .textView(.init(model: block,
                                                      action: .textView(.keyboardAction(.pressKey(.enterAtTheEndOfContent))))))
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(.init(string: NSLocalizedString("Toogle empty Click and drop block inside",
                                                                  comment: ""),
                                        attributes: [.font: UIFont.bodyFont,
                                                     .foregroundColor: UIColor.textColor]),
                                  for: .normal)
        button.contentHorizontalAlignment = .leading
        button.isHidden = true
        button.titleEdgeInsets = Constants.Toggle.titleEdgeInsets
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var currentConfiguration: TextBlockContentConfiguration

    var configuration: UIContentConfiguration {
        get { self.currentConfiguration }
        set {
            guard let configuration = newValue as? TextBlockContentConfiguration else { return }
            self.apply(configuration: configuration)
        }
    }
    private var blockViewModelActionsSubscription: AnyCancellable?

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

    private func makeCoordinator() -> BlockTextViewCoordinator {
        let factory = BlockRestrictionsFactory()
        let restrictions = factory.makeRestrictions(for: currentConfiguration.information.content.type)
        let actionsHandler = BlockMenuActionsHandlerImp(marksPaneActionSubject: currentConfiguration.marksPaneActionSubject,
                                                        addBlockAndActionsSubject: currentConfiguration.toolbarActionSubject)
        let coordinator = BlockTextViewCoordinator(menuItemsBuilder: BlockActionsBuilder(restrictions: restrictions),
                                                    blockMenuActionsHandler: actionsHandler)
        return coordinator.configure(currentConfiguration.viewModel)
    }

    // MARK: - Setup views

    private func setupViews() {
        stackView.layer.cornerRadius = 4
        stackView.layer.cornerCurve = .continuous
        stackView.clipsToBounds = true

        self.topView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(topView)
        stackView.addArrangedSubview(createChildBlockButton)

        addSubview(stackView)

        _ = self.topView.configured(leftChild: .empty())
        _ = self.topView.configured(textView: self.textView)

        self.setupLayout()
    }

    private func setupLayout() {
        stackView.addArrangedSubview(topView)
        stackView.addArrangedSubview(createChildBlockButton)

        createChildBlockButton.heightAnchor.constraint(equalToConstant: 26.5).isActive = true

        stackView.pinAllEdges(to: self, insets: Layout().insets)
    }

    // MARK: - Apply configuration

    private func apply(configuration: TextBlockContentConfiguration) {
        guard self.currentConfiguration != configuration else { return }
        self.currentConfiguration = configuration
        self.applyNewConfiguration()
    }

    private func applyNewConfiguration() {
        self.currentConfiguration.viewModel.addContextMenuIfNeeded(self)

        // it's important to clean old attributed string
        textView.textView.attributedText = nil
        textView.coordinator = makeCoordinator()
        textView.delegate = currentConfiguration.textViewDelegate
        currentConfiguration.viewModel.textView = textView

        guard case let .text(text) = self.currentConfiguration.information.content else { return }
            // In case of configurations is not equal we should check what exactly we should change
            // Because configurations for checkbox block and numbered block may not be equal, so we must rebuld whole view
        createChildBlockButton.isHidden = true
        blockViewModelActionsSubscription = nil
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

        // TODO: textview - do wee need it?
        self.currentConfiguration.viewModel.refreshTextViewModel()

        typealias ColorConverter = MiddlewareModelsModule.Parsers.Text.Color.Converter
        self.stackView.backgroundColor = ColorConverter.asModel(self.currentConfiguration.information.backgroundColor, background: true)

        stackView.layer.borderWidth = 0.0
        stackView.layer.borderColor = nil
        topView.backgroundColor = .clear

        if currentConfiguration.isSelected {
            stackView.layer.borderWidth = 1.0
            stackView.layer.borderColor = UIColor.pureAmber.cgColor
            topView.backgroundColor = UIColor.pureAmber.withAlphaComponent(0.1)
        }
    }
    
    private func setupForPlainText() {
        guard !self.topView.leftView.isNil else  { return }
        _ = self.topView.configured(leftChild: .empty())
        self.textView.textView?.textContainerInset = Constants.Text.textContainerInsets
    }
    
    private func setupForText() {
        self.setupForPlainText()
        self.setupText(placeholer: "", font: .bodyFont)
    }
    
    private func setupForTitle() {
        self.setupForPlainText()
        self.setupText(placeholer: NSLocalizedString("Title", comment: ""), font: .titleFont)
    }
    
    private func setupForHeader1() {
        self.setupForPlainText()
        self.setupText(placeholer: NSLocalizedString("Header 1", comment: ""), font: .header1Font)
    }
    
    private func setupForHeader2() {
        self.setupForPlainText()
        self.setupText(placeholer: NSLocalizedString("Header 2", comment: ""), font: .header2Font)
    }
    
    private func setupForHeader3() {
        self.setupForPlainText()
        self.setupText(placeholer: NSLocalizedString("Header 3", comment: ""), font: .header3Font)
    }
    
    private func setupText(placeholer: String, font: UIFont) {
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor: UIColor.secondaryTextColor]

        self.textView.textView?.update(placeholder: .init(string: placeholer, attributes: attributes))
        self.textView.textView.font = font
        self.textView.textView.typingAttributes = [.font: font]
        self.textView.textView?.defaultFontColor = .textColor
    }
    
    private func setupForCheckbox(checked: Bool) {
        if let button = self.topView.leftView.subviews.first as? UIButton,
           button.tag == Constants.Checkbox.buttonTag {
            button.isSelected = checked
        } else {
            let button: UIButton = .init()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = Constants.Checkbox.buttonTag
            button.setImage(.init(imageLiteralResourceName: Constants.Checkbox.uncheckedImageName), for: .normal)
            button.setImage(.init(imageLiteralResourceName: Constants.Checkbox.checkedImageName), for: .selected)
            button.imageView?.contentMode = .scaleAspectFill
            button.contentVerticalAlignment = .bottom
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.isSelected = checked
            button.addAction(UIAction(handler: { [weak button, weak self] _ in
                guard let self = self, let button = button else { return }
                self.currentConfiguration.viewModel.send(textViewAction: .buttonView(.checkbox(!button.isSelected)))
            }), for: .touchUpInside)
            
            let container: UIView = .init()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(button)
            NSLayoutConstraint.activate([
                container.widthAnchor.constraint(equalTo: button.widthAnchor),
                container.heightAnchor.constraint(greaterThanOrEqualTo: button.heightAnchor),
                button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                button.topAnchor.constraint(equalTo: container.topAnchor, constant: Constants.Checkbox.buttonTopOffset)
            ])
            _ = self.topView.configured(leftChild: container, setConstraints: true)
        }

        self.setupText(placeholer: NSLocalizedString("Checkbox placeholder", comment: ""), font: .bodyFont)
        self.textView.textView?.textContainerInset = Constants.Checkbox.textContainerInsets
        // selected color
        textView.textView.selectedColor = checked ? UIColor.secondaryTextColor : nil
    }
    
    private func setupForBulleted() {
        self.setupText(placeholer: NSLocalizedString("Bulleted placeholder", comment: ""), font: .bodyFont)
        self.textView.textView?.textContainerInset = Constants.Bulleted.textContainerInsets
        let isBulletedView = self.topView.leftView.subviews.first is UIImageView
        guard !isBulletedView else { return }
        
        let view: UIView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let dotView: UIImageView = .init(image: .init(imageLiteralResourceName: Constants.Bulleted.dotImageName))
        dotView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dotView)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Bulleted.viewSide),
            view.widthAnchor.constraint(equalToConstant: Constants.Bulleted.viewSide),
            dotView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.Bulleted.dotTopOffset),
            dotView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        _ = self.topView.configured(leftChild: view, setConstraints: true)
    }
    
    private func setupForNumbered(number: Int) {
        if let label = self.topView.leftView.subviews.first as? UILabel {
            label.textAlignment = number >= Constants.Numbered.numberToPlaceTextLeft ? .left : .center
            label.text = String(number) + "."
        } else {
            let label: UILabel = .init()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .bodyFont
            label.textAlignment = number >= Constants.Numbered.numberToPlaceTextLeft ? .left : .center
            label.text = String(number) + "."
            
            let container: UIView = .init()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)
            NSLayoutConstraint.activate([
                container.widthAnchor.constraint(equalToConstant: Constants.Numbered.leadingViewWidth),
                label.widthAnchor.constraint(equalTo: container.widthAnchor),
                container.heightAnchor.constraint(greaterThanOrEqualTo: label.heightAnchor),
                label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                label.topAnchor.constraint(equalTo: container.topAnchor, constant: Constants.Numbered.labelTopOffset)
            ])
            _ = self.topView.configured(leftChild: container, setConstraints: true)
        }
        self.textView.textView?.textContainerInset = Constants.Numbered.textContainerInsets
        self.setupText(placeholer: NSLocalizedString("Numbered placeholder", comment: ""), font: .bodyFont)
    }
    
    private func setupForQuote() {
        self.textView.textView?.textContainerInset = Constants.Quote.textContainerInsets
        self.setupText(placeholer: NSLocalizedString("Quote placeholder", comment: ""), font: .highlightFont)
        let isQuoteViewExist = self.topView.leftView.subviews.first is QuoteBlockLeadingView
        guard !isQuoteViewExist else { return }
        let view: QuoteBlockLeadingView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: Constants.Quote.viewWidth).isActive = true
        _ = self.topView.configured(leftChild: view, setConstraints: true)
    }
    
    private func setupForToggle() {
        let toggleButton: UIButton?
        if let button = self.topView.leftView.subviews.first as? UIButton,
           button.tag == Constants.Toggle.buttonTag {
            toggleButton = button
        } else {
            let button = makeToggleButton()
            let container: UIView = .init()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(button)
            NSLayoutConstraint.activate([
                container.widthAnchor.constraint(equalTo: button.widthAnchor),
                container.heightAnchor.constraint(greaterThanOrEqualTo: button.heightAnchor),
                button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                button.topAnchor.constraint(equalTo: container.topAnchor, constant: 3)
            ])
            _ = self.topView.configured(leftChild: container, setConstraints: true)
            toggleButton = button
        }
        let toggled = currentConfiguration.viewModel.getBlock().isToggled
        toggleButton?.isSelected = toggled
        setupText(placeholer: NSLocalizedString("Toggle placeholder", comment: ""), font: .bodyFont)
        textView.textView?.textContainerInset = Constants.Toggle.textContainerInsets
        let hasNoChildren = currentConfiguration.viewModel.getBlock().childrenIds().isEmpty
        addBlockViewModelActionsSubscription()
        updateCreateChildButtonState(toggled: toggled, hasChildren: !hasNoChildren)
    }
    
    private func makeToggleButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(imageLiteralResourceName: Constants.Toggle.foldedImageName), for: .normal)
        button.setImage(UIImage(imageLiteralResourceName: Constants.Toggle.unfoldedImageName), for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.addAction(UIAction(handler: { [weak self, weak button] _ in
            guard let self = self else { return }

            let blockViewModel = self.currentConfiguration.viewModel
            button?.isSelected.toggle()
            blockViewModel.update { $0.isToggled.toggle() }
            let toggled = blockViewModel.getBlock().isToggled
            blockViewModel.send(textViewAction: .buttonView(.toggle(.toggled(toggled))))
            let oldValue = self.createChildBlockButton.isHidden
            self.updateCreateChildButtonState(toggled: toggled,
                                              hasChildren: !blockViewModel.getBlock().childrenIds().isEmpty)
            if oldValue != self.createChildBlockButton.isHidden {
                blockViewModel.needsUpdateLayout()
            }
        }), for: .touchUpInside)
        button.tag = Constants.Toggle.buttonTag
        return button
    }
    
    private func addBlockViewModelActionsSubscription() {
        let publisher = currentConfiguration.viewModel.actionsPayloadSubject.eraseToAnyPublisher()

        blockViewModelActionsSubscription = publisher.sink { [weak self] action in
            guard let self = self else { return }

            let blockViewModel = self.currentConfiguration.viewModel

            switch action {
            case let .textView(textViewInteraction):
                switch textViewInteraction.action {
                case let .textView(textView):
                    switch textView {
                    case let .keyboardAction(keyboardAction):
                        switch keyboardAction {
                        case let .pressKey(key):
                            switch key {
                            // We want do hide "Tap on empty..." button if enter was typed in toggle block
                            case .enterInsideContent, .enterOnEmptyContent, .enterAtTheEndOfContent:
                                if !self.createChildBlockButton.isHidden,
                                   self.textView.textView.isFirstResponder,
                                   blockViewModel.getBlock().childrenIds().isEmpty {
                                    self.createChildBlockButton.isHidden = true
                                }
                            // We want to show "Tap on empty..." button, if last child block inside toggle was deleted
                            case .deleteWithPayload, .deleteOnEmptyContent:
                                if self.createChildBlockButton.isHidden,
                                   blockViewModel.getBlock().childrenIds().count == 1,
                                   let lastChild = blockViewModel.getBlock().container?.choose(by: blockViewModel.getBlock().childrenIds()[0]),
                                   lastChild.isFirstResponder {
                                    self.createChildBlockButton.isHidden = false
                                }
                            }
                        }
                    default:
                        break
                    }
                default:
                    break
                }
            default:
                break
            }
        }
    }
    
    private func updateCreateChildButtonState(toggled: Bool, hasChildren: Bool) {
        let shouldShowCreateButton = toggled && !hasChildren
        createChildBlockButton.isHidden = !shouldShowCreateButton
    }
}
