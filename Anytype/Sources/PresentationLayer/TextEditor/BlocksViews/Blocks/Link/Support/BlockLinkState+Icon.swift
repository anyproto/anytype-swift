import UIKit
import BlocksModels
import Kingfisher

extension BlockLinkState {
    
    func makeIconView() -> UIView? {
        if deleted {
            return makeIconImageView(.ghost)
        }
        
        switch style {
        case .noContent:
            return nil
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
    
}

private extension BlockLinkState {
    
    func makeProfileIconView(_ icon: ObjectIconType.Profile) -> UIView {
        switch icon {
        case let .imageId(imageId):
            return makeImageView(imageId: imageId, cornerRadius: Constants.imageViewSize.width / 2)
            
        case let .character(placeholder):
            return makePlaceholderView(placeholder)
        }
    }
    
    func makeImageView(imageId: BlockId, cornerRadius: CGFloat) -> UIImageView {
        let imageView = UIImageView()
        let size = Constants.imageViewSize

        guard let url = ImageID(id: imageId, width: size.width.asImageWidth).resolvedUrl else {
            return imageView
        }
        
        let processor = KFProcessorBuilder(
            scalingType: .resizing(.aspectFill),
            targetSize: size,
            cornerRadius: .point(cornerRadius)
        ).processor
        
        let imageGuideline = ImageGuideline(
            size: size,
            cornerRadius: cornerRadius
        )
        
        let image = ImageBuilder(imageGuideline).build()
        
        imageView.kf.setImage(
            with: url,
            placeholder: image,
            options: [.processor(processor), .transition(.fade(0.2))]
        )
        
        imageView.layoutUsing.anchors {
            $0.size(size)
        }
   
        return imageView
    }
    
    func makeIconImageView(_ image: UIImage?) -> UIView {
        let imageView = UIImageView(image: image)
        
        imageView.layoutUsing.anchors {
            $0.size(Constants.imageViewSize)
        }
        return imageView
    }
    
    func makePlaceholderView(_ placeholder: Character) -> UIView {
        let size = Constants.imageViewSize
        let imageGuideline = ImageGuideline(
            size: size,
            cornerRadius: size.width / 2
        )
        
        let image = ImageBuilder(imageGuideline)
            .setImageColor(.strokePrimary)
            .setText(String(placeholder))
            .setFont(UIFont.systemFont(ofSize: 17))
            .build()
        return makeIconImageView(image)
    }
    
    func makeLabel(with string: String) -> UILabel {
        let label = UILabel()
        label.text = string
        
        label.layoutUsing.anchors {
            $0.size(Constants.imageViewSize)
        }
        return label
    }
    
}

private extension BlockLinkState {
    
    enum Constants {
        static let imageViewSize = CGSize(width: 24, height: 24)
    }
    
}
