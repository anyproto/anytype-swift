import Combine
import UIKit
import BlocksModels

final class CustomTextView: UIView {
    
    weak var delegate: CustomTextViewDelegate? {
        didSet {
            textView.customTextViewDelegate = delegate
        }
    }
    
    var autocorrect = true
    
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
    
    // MARK: - Private functions
    
    private func setupView() {
        textView.delegate = self

        addSubview(textView) {
            $0.pinToSuperview()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesMoved")
        super.touchesMoved(touches, with: event)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
        super.touchesBegan(touches, with: event)
    }

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(Self.handlePanGesture(_:)))
        panGestureRecognizer.minimumNumberOfTouches = 1

        return panGestureRecognizer
    }()


    @objc
    func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        let state = panGesture.state
        switch state {
        case .possible:
            print("=_= possible")
        case .began:
            print("=_= began")
        case .changed:
            print("=_= changed")
        case .ended:
            print("=_= ended")
        case .cancelled:
            print("=_= cancelled")
        case .failed:
            print("=_= failed")
        case .recognized:
            print("=_= recognized")
        }
    }
}

// MARK: - Views

private extension CustomTextView {
    
    func createTextView() -> TextViewWithPlaceholder {
        let textView = TextViewWithPlaceholder(
            frame: .zero,
            textContainer: nil
        )
        
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
            self?.delegate?.showPage(blockId: pageId)
        }
        let mentionSelection = TextViewAttributeSelectionInteraction(
            textView: textView,
            attributeKey: .mention,
            numberOfTapsRequired: 1,
            tapHandler: mentionSelectionHandler
        )
        let objectSelection = TextViewAttributeSelectionInteraction(
            textView: textView,
            attributeKey: .linkToObject,
            numberOfTapsRequired: 1,
            tapHandler: mentionSelectionHandler
        )
        
        textView.addInteraction(linkSelection)
        textView.addInteraction(mentionSelection)
        textView.addInteraction(objectSelection)
        textView.autocorrectionType = autocorrect ? .yes : .no
//
//        textView.addGestureRecognizer(self.panGestureRecognizer)
//        panGestureRecognizer.isEnabled = true

        return textView
    }
}
