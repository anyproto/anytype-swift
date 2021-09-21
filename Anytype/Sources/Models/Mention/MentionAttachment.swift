import UIKit
import Kingfisher
import AnytypeCore
import BlocksModels

final class MentionAttachment: NSTextAttachment {
    private weak var layoutManager: NSLayoutManager?
    
    private let icon: ObjectIconImage?
    private let size: ObjectIconImageMentionType
    
    private let imageView = ObjectIconImageView()
    
    init(icon: ObjectIconImage?, size: ObjectIconImageMentionType) {
        self.icon = icon
        self.size = size
        
        super.init(data: nil, ofType: nil)
        
        icon.flatMap { displayIcon($0) }
    }
    
    private func displayIcon(_ iconImage: ObjectIconImage) {
        imageView.configure(
            model: .init(iconImage: iconImage, usecase: .mention(size))
        )
        
        imageView.imageView.image.flatMap {
            let imageWithPaddingSize = $0.size + CGSize(width: iconSpacing, height: 0)
            let imageWithPadding = $0.imageDrawn(on: imageWithPaddingSize, offset: .zero)
            self.image = imageWithPadding
        }
    }
    
    override func attachmentBounds(
        for textContainer: NSTextContainer?,
        proposedLineFragment lineFrag: CGRect,
        glyphPosition position: CGPoint,
        characterIndex charIndex: Int
    ) -> CGRect {        
        guard let image = self.image else {
            return .zero
        }
        
        return CGRect(origin: .zero, size: image.size)
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
