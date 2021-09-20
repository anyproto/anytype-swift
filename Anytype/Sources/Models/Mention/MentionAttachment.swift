import UIKit
import Kingfisher
import AnytypeCore
import BlocksModels

final class MentionAttachment: NSTextAttachment {
    private weak var layoutManager: NSLayoutManager?
    
    private let icon: ObjectIconImage?
    private let size: ObjectIconImageMentionType
    private var iconSize: CGSize?
    private var fontPointSize: CGFloat?
    private let imageView = ObjectIconImageView()
    
    private var isLoadingMention = false
    
    init(icon: ObjectIconImage?, size: ObjectIconImageMentionType) {
        self.icon = icon
        self.size = size
        
        super.init(data: nil, ofType: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attachmentBounds(
        for textContainer: NSTextContainer?,
        proposedLineFragment lineFrag: CGRect,
        glyphPosition position: CGPoint,
        characterIndex charIndex: Int
    ) -> CGRect {
        let desiredIconSize = CGSize(width: lineFrag.height, height: lineFrag.height)
        layoutManager = textContainer?.layoutManager
    
        let attributedText = textContainer?.layoutManager?.textStorage
        var fontPointSize: CGFloat?
        if let textLength = attributedText?.length,
           textLength > charIndex + 1,
           let font = attributedText?.attribute(.font, at: charIndex + 1, effectiveRange: nil) as? UIFont {
            fontPointSize = font.pointSize
        }
        displayNewImageIfNeeded(
            desiredIconSize: desiredIconSize,
            fontPointSize: fontPointSize
        )
        if let image = self.image {
            return CGRect(origin: .zero, size: image.size)
        }
        return .zero
    }
    
    private func storeParametersForIcon(size: CGSize, fontPointSize: CGFloat?) -> Bool {
        guard let fontPointSize = fontPointSize else { return false }
        var shouldCreateNewImage = true
        if let oldPointSize = self.fontPointSize {
            shouldCreateNewImage = oldPointSize != fontPointSize
        }
        self.iconSize = size
        self.fontPointSize = fontPointSize
        return shouldCreateNewImage
    }
    
    private func displayNewImageIfNeeded(desiredIconSize: CGSize, fontPointSize: CGFloat?) {
        let shouldCreateNewImage = storeParametersForIcon(
            size: desiredIconSize,
            fontPointSize: fontPointSize
        )
        
        if !shouldCreateNewImage {
            return
        }
        if let icon = icon {
            displayIcon(icon)
        }
    }
    
    private func displayIcon(_ iconImage: ObjectIconImage) {
        imageView.configure(
            model: .init(iconImage: iconImage, usecase: .mention(size))
        )
        
        imageView.imageView.image.flatMap {
            addLeadingSpaceAndDisplay($0)
        }
    }
    
    private func addLeadingSpaceAndDisplay(_ image: UIImage) {
        let imageWithSpaceSize = image.size + CGSize(width: iconSpacing, height: 0)
        let imageWithSpace = image.imageDrawn(on: imageWithSpaceSize, offset: .zero)
        
        self.image = imageWithSpace
        
        updateAttachmentLayout()
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
    
    private func updateAttachmentLayout() {
        DispatchQueue.main.async {
            guard let range = self.layoutManager?.rangeForAttachment(attachment: self) else { return }
            
            self.layoutManager?.invalidateLayout(forCharacterRange: range, actualCharacterRange: nil)
        }
    }
}
