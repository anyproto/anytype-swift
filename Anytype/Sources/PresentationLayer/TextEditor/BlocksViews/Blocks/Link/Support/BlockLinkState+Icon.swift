import UIKit
import BlocksModels
import Kingfisher

extension BlockLinkState {
    
    func makeIconView() -> UIView? {
        if deleted {
            return makeIconImageView(UIImage(asset: .ghost))
        }
        
        switch style {
        case .noContent:
            return nil
        case let .icon(icon):
            guard iconSize.hasIcon else { return nil }

            switch icon {
            case let .basic(id):
                return makeImageView(imageId: id, cornerRadius: 4)
                
            case let .profile(profile):
                return makeProfileIconView(profile)
            case let .emoji(emoji):
                return makeEmoji(with: emoji.value)
                
            }
        case let .checkmark(isChecked):
//            let image = isChecked ? UIImage.ObjectIcon.checkmark : UIImage.ObjectIcon.checkbox
            let image = UIImage(asset: isChecked ? .todoCheckmark : .todoCheckbox)
            return makeIconImageView(image)
        }
    }
    
}

private extension BlockLinkState {
    
    func makeProfileIconView(_ icon: ObjectIconType.Profile) -> UIView {
        switch icon {
        case let .imageId(imageId):
            return makeImageView(imageId: imageId, cornerRadius: imageSize.width / 2)
            
        case let .character(placeholder):
            return makePlaceholderView(placeholder)
        }
    }
    
    func makeImageView(imageId: BlockId, cornerRadius: CGFloat) -> UIImageView {
        let imageView = UIImageView()

        let imageGuideline = ImageGuideline(size: imageSize, radius: .point(cornerRadius))
        imageView.wrapper
            .imageGuideline(imageGuideline)
            .setImage(id: imageId)
        
        imageView.layoutUsing.anchors {
            $0.size(imageSize)
        }
   
        return imageView
    }
    
    func makeIconImageView(_ image: UIImage?) -> UIView {
        let imageView = UIImageView(image: image)
        
        imageView.layoutUsing.anchors {
            $0.size(imageSize)
        }
        return imageView
    }
    
    func makePlaceholderView(_ placeholder: Character) -> UIView {
        let imageGuideline = ImageGuideline(size: imageSize, radius: .widthFraction(0.5))
        
        let image = ImageBuilder(imageGuideline)
            .setImageColor(.strokePrimary)
            .setText(String(placeholder))
            .setFont(UIFont.systemFont(ofSize: 17))
            .build()
        return makeIconImageView(image)
    }
    
    func makeEmoji(with string: String) -> UIView {
        switch cardStyle {
        case .text:
            return makeLabelEmoji(with: string)
        case .card:
            return makeEmojiImageView(with: string)
        }
    }

    func makeLabelEmoji(with string: String) -> UILabel {
        let label = UILabel()
        label.text = string

        label.layoutUsing.anchors {
            $0.size(imageSize)
        }
        return label
    }

    func makeEmojiImageView(with string: String) -> UIImageView {
        let painter = ObjectIconImagePainter.shared
        let image = painter.image(
            with: string,
            font: .previewTitle2Regular,
            textColor: .textPrimary,
            imageGuideline: .init(size: imageSize),
            backgroundColor: .clear
        )
        let imageView = UIImageView(image: image)

        imageView.layoutUsing.anchors {
            $0.size(Constants.CardLayout.imageViewSize)
        }
        imageView.backgroundColor = .strokeTransperent
        imageView.layer.cornerRadius = 14

        return imageView
    }

    var imageSize: CGSize {
        if deleted {
            return Constants.TextLayout.imageViewSize
        }
        
        switch cardStyle {
        case .text:
            return Constants.TextLayout.imageViewSize
        case .card:
            switch style {
            case.checkmark:
                return Constants.CardLayout.checkmarkViewSize
            case .icon(let type):
                switch type {
                case .emoji:
                    return Constants.CardLayout.emojiViewSize
                default:
                    return Constants.CardLayout.imageViewSize
                }
            case .noContent:
                return .zero
            }
        }
    }
    
}

private extension BlockLinkState {
    
    enum Constants {
        enum TextLayout {
            static let imageViewSize = CGSize(width: 24, height: 24)
        }

        enum CardLayout {
            static let imageViewSize = CGSize(width: 64, height: 64)
            static let emojiViewSize = CGSize(width: 36, height: 36)
            static let checkmarkViewSize = CGSize(width: 28, height: 28)
        }
    }
    
}
