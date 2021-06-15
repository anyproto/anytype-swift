import UIKit
import Combine


final class BlockPageLinkUIKitView: UIView {

    private enum Constants {
        static let imageViewWidth: CGFloat = 24
        static let textContainerInset: UIEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 8)
    }
    
    // MARK: Views
    // |    topView    | : | leftView | textView |
    // |   leftView    | : |  button  |
    let topView: TopWithChildUIKitView = .init()
    let textView: UITextView = {
        let placeholder = NSAttributedString(string: NSLocalizedString("Untitled", comment: ""),
                                             attributes: [.foregroundColor: UIColor.secondaryTextColor,
                                                          .font: UIFont.bodyFont])
        let view = UITextView()
        view.isScrollEnabled = false
        view.attributedText = placeholder
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
    }
    
    // MARK: UI Elements
    func setupUIElements() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.topView)
        self.configured(textView: self.textView)
    }
                    
    // MARK: Configured
    func configured(textView: UITextView) {
        _ = self.topView.configured(textView: textView)
        textView.font = .bodyFont
        textView.typingAttributes = [.font: UIFont.bodyFont,
                                               .foregroundColor: UIColor.textColor,
                                               .underlineStyle: NSUnderlineStyle.single.rawValue,
                                               .underlineColor: UIColor.textColor]
        textView.textContainerInset = Constants.textContainerInset
        textView.textColor = .textColor
        textView.isUserInteractionEnabled = false
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
        textView.text = state.title
    }
}
