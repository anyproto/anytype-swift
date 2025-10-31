import UIKit
import AnytypeCore
import Services

final class IconTextAttachment: NSTextAttachment, @unchecked Sendable {
    let icon: Icon?
    let size: CGSize
    let rightPadding: CGFloat
    
    private init(icon: Icon?, size: CGSize, rightPadding: CGFloat = 0) {
        self.icon = icon
        self.size = size
        self.rightPadding = rightPadding
        super.init(data: nil, ofType: "com.anytype.mention")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let otherObject = object as? IconTextAttachment {
            return self.hash == otherObject.hash
        }
        
        return false
    }
    
    override var hash: Int {
        (icon?.hashValue ?? 0)
            .addingReportingOverflow(size.hashValue).partialValue
            .addingReportingOverflow(rightPadding.hashValue).partialValue
    }
    
    override func attachmentBounds(
        for textContainer: NSTextContainer?,
        proposedLineFragment lineFrag: CGRect,
        glyphPosition position: CGPoint,
        characterIndex charIndex: Int
    ) -> CGRect {
        guard icon.isNotNil else { 
            return .zero
        }
        
        let textStorage: NSTextStorage? = textContainer?.layoutManager?.textStorage
        let anyAttribute: Any? = textStorage?.attribute(.font, at: charIndex, effectiveRange: nil)

        guard let font = anyAttribute as? UIFont else {
            return CGRect(origin: .zero, size: size)
        }

        // Centering image in the middle of text.
        // Attachment is laied out on the base line in core graphics coordinate system (aka y axis go up)
        // Offset from line center to baseline
        let yOffset: CGFloat = font.ascender - (font.lineHeight / 2.0)
        // Shift image to center take into account the offset
        let imageYPoint: CGFloat = -(size.height / 2.0) + yOffset
        let imageOrigin = CGPoint(x: .zero, y: imageYPoint)

        return CGRect(origin: imageOrigin, size: CGSize(width: size.width + rightPadding, height: size.height))
    }
    
    override func viewProvider(for parentView: UIView?, location: any NSTextLocation, textContainer: NSTextContainer?) -> NSTextAttachmentViewProvider? {
        super.viewProvider(for: parentView, location: location, textContainer: textContainer)
    }

    override var usesTextAttachmentView: Bool {
        super.usesTextAttachmentView
    }
}

extension IconTextAttachment {
    static func iconTextAttachment(icon: Icon?, mentionType: ObjectIconImageMentionType) -> IconTextAttachment {
        IconTextAttachment.init(
            icon: icon,
            size: mentionType.size,
            rightPadding: mentionType.iconSpacing
        )
    }
}

final class IconTextAttachmentViewProvider: NSTextAttachmentViewProvider, @unchecked Sendable {
    override init(textAttachment: NSTextAttachment, parentView: UIView?, textLayoutManager: NSTextLayoutManager?, location: any NSTextLocation) {
        super.init(textAttachment: textAttachment, parentView: parentView, textLayoutManager: textLayoutManager, location: location)
        
        tracksTextAttachmentViewBounds = true
    }
    
    override func loadView() {
        guard let mentionAttachment = textAttachment as? IconTextAttachment else {
            anytypeAssertionFailure("Text attachment type is not IconTextAttachment", info: ["type": String(describing: textAttachment)])
            return
        }
        guard let icon = mentionAttachment.icon else {
            view = MainActor.assumeIsolated {
                return UIView()
            }
            return
        }
        let rightPadding = mentionAttachment.rightPadding
        let container = MainActor.assumeIsolated { () -> UIView in
            let container = UIView()
            let iconView = IconViewUIKit()
            iconView.isUserInteractionEnabled = false
            container.addSubview(iconView) {
                $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rightPadding))
            }
            iconView.icon = icon
            return container
        }
        view = container
    }
}

private extension ObjectIconImageMentionType {
    
    var iconSpacing: CGFloat {
        switch self {
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
    
    var size: CGSize {
        switch self {
        case .title:
            return CGSize(width: 28, height: 28)
        case .heading:
            return CGSize(width: 24, height: 24)
        case .subheading, .body:
            return CGSize(width: 20, height: 20)
        case .callout:
            return CGSize(width: 18, height: 18)
        }
    }
}
