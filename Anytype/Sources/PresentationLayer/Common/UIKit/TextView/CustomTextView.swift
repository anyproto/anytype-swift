import Combine
import UIKit
import BlocksModels

final class CustomTextView: UIView {
    
    weak var delegate: TextViewDelegate?
    weak var userInteractionDelegate: TextViewUserInteractionProtocol? {
        didSet {
            textView.userInteractionDelegate = userInteractionDelegate
        }
    }
    
    var textSize: CGSize?

    private(set) lazy var textView = createTextView()
    let accessoryViewSwitcher: AccessoryViewSwitcher
    
    private var firstResponderSubscription: AnyCancellable?

    let options: CustomTextViewOptions
    
    init(
        options: CustomTextViewOptions,
        accessoryViewSwitcher: AccessoryViewSwitcher
    ) {
        self.options = options
        self.accessoryViewSwitcher = accessoryViewSwitcher
        super.init(frame: .zero)

        setupView()
        configureEditingToolbarHandler()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        .zero
    }

}

// MARK: - BlockTextViewInput

extension CustomTextView: TextViewManagingFocus {
    
    func shouldResignFirstResponder() {
        _ = textView.resignFirstResponder()
    }

    func setFocus(_ focus: BlockFocusPosition?) {
        guard let focus = focus else { return }
        
        textView.setFocus(focus)
    }

    func obtainFocusPosition() -> BlockFocusPosition? {
        guard textView.isFirstResponder else { return nil }
        let caretLocation = textView.selectedRange.location
        if caretLocation == 0 {
            return .beginning
        }
        return .at(textView.selectedRange)
    }
}

// MARK: - Private extension

private extension CustomTextView {
    
    func setupView() {
        textView.delegate = self

        addSubview(textView) {
            $0.pinToSuperview()
        }
        
        firstResponderSubscription = textView.firstResponderChangePublisher
            .sink { [weak self] change in
                self?.delegate?.changeFirstResponderState(change)
            }
    }

    func configureEditingToolbarHandler() {
        accessoryViewSwitcher.editingToolbarAccessoryView.setActionHandler { [weak self] action in
            guard let self = self else { return }

            self.accessoryViewSwitcher.switchInputs(textView: self.textView)

            switch action {
            case .slashMenu:
                self.textView.insertStringToAttributedString(
                    self.accessoryViewSwitcher.textToTriggerActionsViewDisplay
                )
                self.accessoryViewSwitcher.showSlashMenuView(
                    textView: self.textView
                )
            case .multiActionMenu:
                self.userInteractionDelegate?.didReceiveAction(
                    .showMultiActionMenuAction
                )

            case .showStyleMenu:
                self.userInteractionDelegate?.didReceiveAction(.showStyleMenu)

            case .keyboardDismiss:
                UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
            case .mention:
                self.textView.insertStringToAttributedString(
                    self.accessoryViewSwitcher.textToTriggerMentionViewDisplay
                )
                self.accessoryViewSwitcher.showMentionsView(
                    textView: self.textView
                )
            }
        }
    }
}

extension CustomTextView {
    func createTextView() -> TextViewWithPlaceholder {
        let textView = TextViewWithPlaceholder()
        textView.textContainer.lineFragmentPadding = 0.0
        textView.isScrollEnabled = false
        textView.backgroundColor = nil
        textView.autocorrectionType = options.autocorrect ? .yes : .no
        return textView
    }
}
