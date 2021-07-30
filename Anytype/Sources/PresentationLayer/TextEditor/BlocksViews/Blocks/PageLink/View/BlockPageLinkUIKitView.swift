import UIKit
import Combine
import BlocksModels
import Kingfisher

final class BlockPageLinkUIKitView: UIView {

    private enum Constants {
        static let imageViewWidth: CGFloat = 24
        static let imageViewHeight: CGFloat = 24
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
        addSubview(topView) {
            $0.pinToSuperview()
        }
        
        topView.configured(view: textView)
    }

    func apply(_ state: BlockPageLinkState) {
        topView.updateIfNeeded(leftChild: {
            switch state.style {
            case .noContent:
                return placeholder()
            case let .icon(icon):
                switch icon {
                case let .basic(basic):
                    switch basic {
                    case let .emoji(emoji):
                        return string(string: emoji.value)
                    case let .imageId(imageId):
                        return image(imageId: imageId)
                    }
                case let .profile(proile):
                    switch proile {
                    case let .imageId(imageId):
                        return image(imageId: imageId)
                    case let .placeholder(placeloder):
                        return string(string: "\(placeloder)")
                    }
                }
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
    
    
    
    private func image(imageId: BlockId) -> UIImageView {
        let imageView = UIImageView()
        imageView.kf.setImage(
            with: UrlResolver.resolvedUrl(.image(id: imageId, width: .thumbnail))
//            placeholder: placeholder TODO
        )
        imageView.layoutUsing.anchors {
            $0.width.equal(to: Constants.imageViewWidth)
            $0.height.equal(to: Constants.imageViewHeight)
        }
   
        return imageView
    }
    
    private func placeholder() -> UIView {
        let imageView = UIImageView(image: UIImage(named: "TextEditor/Style/Page/empty"))
        
        imageView.layoutUsing.anchors {
            $0.width.equal(to: Constants.imageViewWidth)
            $0.height.equal(to: Constants.imageViewHeight)
        }
        return imageView
    }
    
    private func string(string: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = string
        return label
    }
}
