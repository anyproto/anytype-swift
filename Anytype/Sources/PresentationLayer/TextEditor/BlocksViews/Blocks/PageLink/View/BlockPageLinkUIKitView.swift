import UIKit
import Combine
import BlocksModels
import Kingfisher

final class BlockPageLinkUIKitView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private func setup() {
        addSubview(leftView) {
            $0.pinToSuperview(excluding: [.right])
        }
        addSubview(textView) {
            $0.pinToSuperview(excluding: [.left])
            $0.leading.equal(to: leftView.trailingAnchor)
        }
    }

    func apply(_ state: BlockPageLinkState) {
        leftView.removeAllSubviews()
        leftView.addSubview(iconView(state: state)) {
            $0.pinToSuperview()
        }
        textView.text = !state.title.isEmpty ? state.title : "Untitled"        
    }
    
    private func iconView(state: BlockPageLinkState) -> UIView {
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
        label.text = string
        return label
    }
    
    // MARK: - Views
    private let leftView = UIView()
    
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
          
    // MARK: - Constants
    private enum Constants {
        static let imageViewWidth: CGFloat = 24
        static let imageViewHeight: CGFloat = 24
        static let textContainerInset: UIEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 8)
    }
    
}
