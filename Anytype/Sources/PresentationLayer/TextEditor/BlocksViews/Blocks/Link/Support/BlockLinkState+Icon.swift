import UIKit
import Services
import AnytypeCore

extension BlockLinkState {

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
        }
        
        guard let icon, iconSize.hasIcon, !iconIntendHidden else {
            let attributedString = NSAttributedString(
                string: titleText,
                attributes: attributes
            )

            label.setText(attributedString)
            return
        }

        let painter = IconMaker(icon: icon, size: imageSize)
        let placeholder = painter.makePlaceholder()
        let attributedText = NSAttributedString.imageFirstComposite(
            image: placeholder,
            text: titleText,
            attributes: attributes
        )
        label.setText(attributedText)
        Task { @MainActor in
            
            let image = await painter.make()
            
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
        spaceWidth: CGFloat = 6,
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
        spacerAttachmenent.bounds = .init(origin: .zero, size: .init(width: spaceWidth, height: 0.001))
        
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
