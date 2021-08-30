import UIKit
import BlocksModels
import Kingfisher

struct BlockLinkIconMaker {
    private let imageViewSize = CGSize(width: 24, height: 24)
    
    func makeIconView(state: BlockLinkState) -> UIView {
        switch state.style {
        case .noContent:
            return makeIconImageView()
        case let .icon(icon):
            switch icon {
            case let .basic(id):
                return makeImageView(imageId: id, cornerRadius: 4)
                
            case let .profile(profile):
                return makeProfileIconView(profile)
            case let .emoji(emoji):
                return makeLabel(with: emoji.value)
                
            }
        case let .checkmark(isChecked):
            let image = isChecked ? UIImage.ObjectIcon.checkmark : UIImage.ObjectIcon.checkbox
            
            return makeIconImageView(image)
        }
    }
    
    private func makeProfileIconView(_ icon: ObjectIconType.Profile) -> UIView {
        switch icon {
        case let .imageId(imageId):
            return makeImageView(imageId: imageId, cornerRadius: imageViewSize.width / 2)
            
        case let .character(placeholder):
            return makePlaceholderView(placeholder)
        }
    }
    
    private func makeImageView(imageId: BlockId, cornerRadius: CGFloat) -> UIImageView {
        let imageView = UIImageView()
        
        guard let url = UrlResolver.resolvedUrl(.image(id: imageId, width: .thumbnail)) else {
            return imageView
        }
        
        let size = imageViewSize
        
        let processor = KFProcessorBuilder(
            scalingType: .resizing(.aspectFill),
            targetSize: size,
            cornerRadius: .point(cornerRadius)
        ).processor
        
        let imageGuideline = ImageGuideline(
            size: size,
            cornerRadius: cornerRadius
        )
        
        let image = ImageBuilder(imageGuideline)
            .setImageColor(.grayscale30)
            .build()
        
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
    
    private func makeIconImageView(_ image: UIImage? = UIImage(named: "TextEditor/Style/Page/empty") ) -> UIView {
        let imageView = UIImageView(image: image)
        
        imageView.layoutUsing.anchors {
            $0.size(imageViewSize)
        }
        return imageView
    }
    
    private func makePlaceholderView(_ placeholder: Character) -> UIView {
        let size = imageViewSize
        let imageGuideline = ImageGuideline(
            size: size,
            cornerRadius: size.width / 2
        )
        
        let image = ImageBuilder(imageGuideline)
            .setImageColor(.grayscale30)
            .setText(String(placeholder))
            .setFont(UIFont.systemFont(ofSize: 17))
            .build()
        return makeIconImageView(image)
    }
    
    private func makeLabel(with string: String) -> UILabel {
        let label = UILabel()
        label.text = string
        
        label.layoutUsing.anchors {
            $0.size(imageViewSize)
        }
        return label
    }
}
