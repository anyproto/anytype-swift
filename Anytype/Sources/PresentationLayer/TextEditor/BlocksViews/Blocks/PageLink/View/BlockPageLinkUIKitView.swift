import UIKit
import Combine


final class BlockPageLinkUIKitView: UIView {

    private enum Constants {
        static let imageViewWidth: CGFloat = 24
        static let textContainerInset: UIEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 8)
    }
    
    let topView = TopWithChildUIKitView()
    private let textView: UITextView = {
        let view = UITextView()
        view.isScrollEnabled = false
        view.font = .body
        view.typingAttributes = [
            .font: UIFont.body,
            .foregroundColor: UIColor.textColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.textColor
        ]
        view.textContainerInset = Constants.textContainerInset
        view.textColor = .textColor
        view.isUserInteractionEnabled = false
        return view
    }()
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        topView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topView)
        _ = topView.configured(textView: textView)
        topView.edgesToSuperview()
    }

    func apply(_ state: BlockPageLinkState) {
        _ = self.topView.configured(leftChild: {
            switch state.style {
            case .noContent:
                let imageView = UIImageView(image: UIImage(named: "TextEditor/Style/Page/empty"))
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
        if !state.title.isEmpty {
            textView.text = state.title
        } else {
            textView.attributedText = NSAttributedString(
                string: "Untitled".localized,
                attributes: textView.typingAttributes
            )
        }
    }
}
