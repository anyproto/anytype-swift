import UIKit
import Services
import AnytypeCore

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

