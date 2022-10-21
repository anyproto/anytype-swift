import UIKit
import BlocksModels

extension BlockLinkState {
    var iconImage: ObjectIconImage? {
        switch style {
        case .noContent:
            return nil
        case .checkmark(let isChecked):
            return .todo(isChecked)
        case .icon(let iconType):
            return .icon(iconType)
        }
    }

    func applyTitleState(
        on label: UILabel,
        attributes: [NSAttributedString.Key : Any],
        iconIntendHidden: Bool = false
    ) {
        if archived, let ghostImage = UIImage(asset: .ghost) {
            label.attributedText = NSAttributedString.imageFirstComposite(
                image: ghostImage,
                text: titleText,
                attributes: attributes
            )

            return 
        } else if style == .noContent || !iconSize.hasIcon || iconIntendHidden {
            label.attributedText = .init(
                string: titleText,
                attributes: attributes
            )

            return
        }

        let image = UIImage.circleImage(
            size: imageSize,
            fillColor: .strokePrimary,
            borderColor: .clear,
            borderWidth: 0
        )

        label.attributedText = NSAttributedString.imageFirstComposite(
            image: image,
            text: titleText,
            attributes: attributes
        )

        let anytypeLoader = AnytypeIconDownloader()

        Task { @MainActor in
            guard let image = await anytypeLoader.image(with: style, imageGuideline: .init(size: imageSize)) else {
                return
            }

            label.attributedText = NSAttributedString.imageFirstComposite(
                image: image,
                text: titleText,
                attributes: attributes
            )
        }
    }
}

extension NSAttributedString {
    static func imageFirstComposite(
        image: UIImage,
        text: String,
        spacerText: String = "  ",
        attributes: [NSAttributedString.Key : Any]
    ) -> NSAttributedString {
        let font = (attributes[.font] as? UIFont) ?? UIFont.preferredFont(forTextStyle: .body)

        let textAttachment = NSTextAttachment()
        textAttachment.image = image

        textAttachment.bounds = CGRect(
            x: 0,
            y: (font.capHeight - image.size.height).rounded() / 2,
            width: image.size.width,
            height: image.size.height
        )

        let textAttributedString = NSAttributedString(string: text, attributes: attributes)

        let compositeAttributedString = NSMutableAttributedString(attachment: textAttachment)
        
        compositeAttributedString.append(.init(string: spacerText))

        compositeAttributedString.append(textAttributedString)

        return compositeAttributedString
    }
}

private extension BlockLinkState {
    
    func makeProfileIconView(_ icon: ObjectIconType.Profile) -> UIView {
        switch icon {
        case let .imageId(imageId):
            return makeImageView(imageId: imageId, cornerRadius: imageSize.width / 2)
            
        case let .character(placeholder):
            return makeIconImageView(makePlaceholderImage(placeholder))
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
    
    func makePlaceholderImage(_ placeholder: Character) -> UIImage {
        let imageGuideline = ImageGuideline(size: imageSize, radius: .widthFraction(0.5))
        
        return ImageBuilder(imageGuideline)
            .setImageColor(.strokePrimary)
            .setText(String(placeholder))
            .setFont(UIFont.systemFont(ofSize: 17))
            .build()
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
        Constants.TextLayout.imageViewSize
    }
    
}

private extension BlockLinkState {
    
    enum Constants {
        enum TextLayout {
            static let imageViewSize = CGSize(width: 22, height: 22)
        }

        enum CardLayout {
            static let imageViewSize = CGSize(width: 64, height: 64)
            static let emojiViewSize = CGSize(width: 36, height: 36)
            static let checkmarkViewSize = CGSize(width: 28, height: 28)
        }
    }
    
}
