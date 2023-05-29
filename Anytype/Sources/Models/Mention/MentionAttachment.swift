import UIKit
import Kingfisher
import AnytypeCore
import BlocksModels

final class MentionAttachment: NSTextAttachment {    
    private let icon: ObjectIconImage?
    private let size: ObjectIconImageMentionType
    
    private let loader = ObjectIconAttachementLoader()
    
    init(icon: ObjectIconImage?, size: ObjectIconImageMentionType) {
        self.icon = icon
        self.size = size
        
        super.init(data: nil, ofType: nil)
        
        icon.flatMap { displayIcon($0) }
    }
    
    private func displayIcon(_ iconImage: ObjectIconImage) {
        loader.attachement = self
        loader.configure(
            model: ObjectIconImageModel(iconImage: iconImage, usecase: .mention(size)),
            processor: MentionImageProcessor(rightPadding: iconSpacing)
        )
    }
    
    override func attachmentBounds(
        for textContainer: NSTextContainer?,
        proposedLineFragment lineFrag: CGRect,
        glyphPosition position: CGPoint,
        characterIndex charIndex: Int
    ) -> CGRect {        
        guard let image = self.image else { return .zero }

        let textStorage: NSTextStorage? = textContainer?.layoutManager?.textStorage
        let anyAttribute: Any? = textStorage?.attribute(.font, at: charIndex, effectiveRange: nil)
        
        guard let font = anyAttribute as? UIFont else {
            return CGRect(origin: .zero, size: image.size)
        }

        // Centering image in the middle of text.
        // Attachment is laied out on the base line in core graphics coordinate system (aka y axis go up)
        // Offset from line center to baseline
        let yOffset: CGFloat = font.ascender - (font.lineHeight / 2.0)
        // Shift image to center take into account the offset
        let imageYPoint: CGFloat = -(image.size.height / 2.0) + yOffset
        let imageOrigin = CGPoint(x: .zero, y: imageYPoint)

        return CGRect(origin: imageOrigin, size: image.size)
    }
    
    private var iconSpacing: CGFloat {
        switch size {
        case .title:
            return 8
        case .heading:
            return 6
        case .subheading, .body:
            return 5
        case .callout:
            return 4
        }
    }
    
    // MARK: - Unavailable
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
