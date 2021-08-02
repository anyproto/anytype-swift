import UIKit
import Combine
import BlocksModels
import Kingfisher

final class BlockPageLinkUIKitView: UIView {
    
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
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    // MARK: - Internal functions
    func apply(_ state: BlockPageLinkState) {
        leftView.removeAllSubviews()
        leftView.addSubview(makeIconView(state: state)) {
            $0.pinToSuperview()
        }
        textView.text = !state.title.isEmpty ? state.title : "Untitled"        
    }
    
    // MARK: - Private functions
    
    private func setup() {
        addSubview(leftView) {
            $0.pinToSuperview(excluding: [.right])
        }
        addSubview(textView) {
            $0.pinToSuperview(excluding: [.left])
            $0.leading.equal(to: leftView.trailingAnchor)
        }
    }
    
    private func makeIconView(state: BlockPageLinkState) -> UIView {
        switch state.style {
        case .noContent:
            return makePlaceholderView()
            
        case let .icon(icon):
            switch icon {
            case let .basic(basic):
                return makeBasicIconView(basic)
                
            case let .profile(profile):
                return makeProfileIconView(profile)
            }
        }
    }
    
    private func makeBasicIconView(_ icon: DocumentIconType.Basic) -> UIView {
        switch icon {
        case let .emoji(emoji):
            return makeLabel(with: emoji.value)
            
        case let .imageId(imageId):
            return makeImageView(imageId: imageId, cornerRadius: 4)
        }
    }
    
    private func makeProfileIconView(_ icon: DocumentIconType.Profile) -> UIView {
        switch icon {
        case let .imageId(imageId):
            return makeImageView(imageId: imageId, cornerRadius: Constants.imageViewSize.width / 2)
            
        case let .placeholder(placeloder):
            return makeLabel(with: "\(placeloder)")
        }
    }
    
    private func makeImageView(imageId: BlockId, cornerRadius: CGFloat) -> UIImageView {
        let imageView = UIImageView()
        
        guard let url = UrlResolver.resolvedUrl(.image(id: imageId, width: .thumbnail)) else {
            return imageView
        }
        
        let size = Constants.imageViewSize
        
        let processor = ResizingImageProcessor(
            referenceSize: size,
            mode: .aspectFill
        )
            |> CroppingImageProcessor(size: size)
            |> RoundCornerImageProcessor(radius: .point(cornerRadius))
        
        
        let imageGuideline = ImageGuideline(
            size: size,
            cornerRadius: cornerRadius
        )
        
        let image = PlaceholderImageBuilder.placeholder(
            with: imageGuideline,
            color: .grayscale30
        )
        
        imageView.kf.setImage(
            with: url,
            placeholder: image,
            options: [.processor(processor)]
        )
        
        imageView.layoutUsing.anchors {
            $0.size(size)
        }
   
        return imageView
    }
    
    private func makePlaceholderView() -> UIView {
        let imageView = UIImageView(image: UIImage(named: "TextEditor/Style/Page/empty"))
        
        imageView.layoutUsing.anchors {
            $0.size(Constants.imageViewSize)
        }
        return imageView
    }
    
    private func makeLabel(with string: String) -> UILabel {
        let label = UILabel()
        label.text = string
        
        label.layoutUsing.anchors {
            $0.size(Constants.imageViewSize)
        }
        return label
    }
    
}

// MARK: - Constants

private extension BlockPageLinkUIKitView {
    
    enum Constants {
        static let imageViewSize = CGSize(width: 24, height: 24)
        static let textContainerInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 8)
    }
    
}
