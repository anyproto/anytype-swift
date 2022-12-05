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
        on label: AnytypeLabel,
        font: AnytypeFont,
        iconIntendHidden: Bool = false
    ) {
        let attributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: titleColor,
            .font: font.uiKitFont
        ]
        if archived, let ghostImage = UIImage(asset: .ghost) {

            let attributedString = NSAttributedString.imageFirstComposite(
                image: ghostImage,
                text: titleText,
                attributes: attributes
            )

            label.setText(attributedString)
            return 
        } else if style == .noContent || !iconSize.hasIcon || iconIntendHidden {
            let attributedString = NSAttributedString(
                string: titleText,
                attributes: attributes
            )

            label.setText(attributedString)
            return
        }

        let image = UIImage.circleImage(
            size: imageSize,
            fillColor: .strokePrimary,
            borderColor: .clear,
            borderWidth: 0
        )

        let attributedText = NSAttributedString.imageFirstComposite(
            image: image,
            text: titleText,
            attributes: attributes
        )

        label.setText(attributedText)

        let anytypeLoader = AnytypeIconDownloader()

        Task { @MainActor in
            guard let image = await anytypeLoader.image(with: style, imageGuideline: .init(size: imageSize)) else {
                return
            }

            let attributedText = NSAttributedString.imageFirstComposite(
                image: image,
                text: titleText,
                attributes: attributes
            )

            label.setText(attributedText)
        }
    }
}

extension NSAttributedString {
    static func imageFirstComposite(
        image: UIImage,
        text: String,
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
        
        let spacerAttachmenent = NSTextAttachment()
        spacerAttachmenent.image = UIImage()
        spacerAttachmenent.bounds = .init(origin: .zero, size: .init(width: 6, height: 0.001))
        
        compositeAttributedString.append(.init(attachment: spacerAttachmenent))

        compositeAttributedString.append(textAttributedString)

        return compositeAttributedString
    }
}

private extension BlockLinkState {
    var imageSize: CGSize {
        switch cardStyle {
        case .card:
            return .init(width: 18, height: 18)
        case .text:
            return .init(width: 20, height: 20)
        }
    }
}
