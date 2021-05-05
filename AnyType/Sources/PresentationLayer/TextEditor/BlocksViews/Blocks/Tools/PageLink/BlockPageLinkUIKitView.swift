import UIKit
import Combine

final class BlockPageLinkUIKitView: UIView {

    private enum Constants {
        static let imageViewWidth: CGFloat = 24
        static let textContainerInset: UIEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 8)
    }
    
    // MARK: Publishers
    private var subscriptions: Set<AnyCancellable> = []
    private var stateStream: AnyPublisher<BlockPageLinkState, Never> = .empty() {
        willSet {
            self.subscriptions = []
        }
        didSet {
            stateStream.reciveOnMain().sink { [weak self] (value) in
                self?.apply(value)
            }.store(in: &self.subscriptions)
        }
    }
    @Published private var state: BlockPageLinkState = .empty
    
    // MARK: Views
    // |    topView    | : | leftView | textView |
    // |   leftView    | : |  button  |
    
    let topView: TopWithChildUIKitView = .init()
    let textView: TextView.UIKitTextView = {
        let placeholder = NSAttributedString(string: NSLocalizedString("Untitled", comment: ""),
                                             attributes: [.foregroundColor: UIColor.secondaryTextColor,
                                                          .font: UIFont.bodyFont])
        let view = TextView.UIKitTextView()
        view.textView.update(placeholder: placeholder)
        return view
    }()
            
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    // MARK: Setup
    func setup() {
        self.setupUIElements()
        self.self.topView.edgesToSuperview()
        self.apply(self.state)
    }
    
    // MARK: UI Elements
    func setupUIElements() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.topView)
        self.configured(textView: self.textView)
    }
                    
    // MARK: Configured
    func configured(textView: TextView.UIKitTextView?) {
        _ = self.topView.configured(textView: textView)
        textView?.textView.font = .bodyFont
        textView?.textView.typingAttributes = [.font: UIFont.bodyFont,
                                               .foregroundColor: UIColor.textColor,
                                               .underlineStyle: NSUnderlineStyle.single.rawValue,
                                               .underlineColor: UIColor.textColor]
        textView?.textView.textContainerInset = Constants.textContainerInset
        textView?.textView.defaultFontColor = .textColor
        textView?.textView?.isUserInteractionEnabled = false
    }
    
    func configured(stateStream: AnyPublisher<BlockPageLinkState, Never>) -> Self {
        self.stateStream = stateStream
        return self
    }
    
    func configured(state: Published<BlockPageLinkState>) -> Self {
        self._state = state
        return self
    }
}

extension BlockPageLinkUIKitView {
    func apply(_ state: BlockPageLinkState) {
        _ = self.topView.configured(leftChild: {
            switch state.style {
            case .noContent, .noEmoji:
                let imageView = UIImageView(image: UIImage(named: state.style.resource))
                imageView.translatesAutoresizingMaskIntoConstraints = false
                
                let container = UIView()
                container.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(imageView)
                NSLayoutConstraint.activate([
                    container.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                    container.widthAnchor.constraint(equalToConstant: Constants.imageViewWidth),
                    container.heightAnchor.constraint(greaterThanOrEqualTo: imageView.heightAnchor),
                    container.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
                ])
                return container
                
            case let .emoji(value):
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = value
                return label
            }
        }())
        self.textView.textView.text = state.title
    }
}
