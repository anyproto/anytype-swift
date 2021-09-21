import Combine
import UIKit
import BlocksModels

final class CustomTextView: UIView {
    
    weak var delegate: CustomTextViewDelegate? {
        didSet {
            textView.customTextViewDelegate = delegate
        }
    }

    var textSize: CGSize?
    
    var options = CustomTextViewOptions(createNewBlockOnEnter: false, autocorrect: false)
    
    // MARK: - Private variables
    
    private(set) lazy var textView = createTextView()
    private var firstResponderSubscription: AnyCancellable?
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides
    
    override var intrinsicContentSize: CGSize {
        .zero
    }
    
    // MARK: - Internal functions
    
    func setCustomTextViewOptions(options: CustomTextViewOptions) {
        self.options = options
    }
    
    // MARK: - Private functions
    
    private func setupView() {
        textView.delegate = self

        addSubview(textView) {
            $0.pinToSuperview()
        }
    }
    
}

// MARK: - BlockTextViewInput

extension CustomTextView: TextViewManagingFocus {
    
    func shouldResignFirstResponder() {
        _ = textView.resignFirstResponder()
    }

    func setFocus(_ position: BlockFocusPosition) {
        textView.setFocus(position)
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

// MARK: - Views

private extension CustomTextView {
    
    func createTextView() -> TextViewWithPlaceholder {
        let textView = TextViewWithPlaceholder(
            frame: .zero,
            textContainer: nil
        ) { [weak self] change in
            self?.delegate?.changeFirstResponderState(change)
        }
        
        textView.textContainer.lineFragmentPadding = 0.0
        textView.isScrollEnabled = false
        textView.backgroundColor = nil
        textView.linkTextAttributes = [:]
        textView.removeInteractions { interaction in
            return interaction is UIContextMenuInteraction ||
            interaction is UIDragInteraction ||
            interaction is UIDropInteraction
        }
        let linkSelection = TextViewAttributeSelectionInteraction(
            textView: textView,
            attributeKey: .link,
            numberOfTapsRequired: 2,
            tapHandler: LinkAttributeSelectionHandler()
        )
        let mentionSelectionHandler = MentionAttributeSelectionHandler { [weak self] pageId in
            self?.delegate?.didReceiveAction(.showPage(pageId))
        }
        let mentionSelection = TextViewAttributeSelectionInteraction(
            textView: textView,
            attributeKey: .mention,
            numberOfTapsRequired: 1,
            tapHandler: mentionSelectionHandler
        )
        
        textView.addInteraction(linkSelection)
        textView.addInteraction(mentionSelection)
        textView.autocorrectionType = options.autocorrect ? .yes : .no
        return textView
    }
    
}
