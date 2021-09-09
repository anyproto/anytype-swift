import UIKit
import Kingfisher
import AnytypeCore
import BlocksModels

final class MentionAttachment: NSTextAttachment {
    
    let pageId: BlockId
    let name: String
    
    private weak var layoutManager: NSLayoutManager?
    
    private let mentionService = MentionObjectsService(
        searchService: ServiceLocator.shared.searchService()
    )
    
    private var icon: ObjectIconImage?
    private var iconSize: CGSize?
    private var fontPointSize: CGFloat?
    private let imageView = ObjectIconImageView()
    
    private var isLoadingMention = false
    
    init(name: String, pageId: String, icon: ObjectIconImage?) {
        self.pageId = pageId
        self.name = name
        self.icon = icon
        
        super.init(data: nil, ofType: nil)
        
        mentionService.filterString = name
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
           let font = attributedText?.attribute(.font,
                                                at: charIndex + 1,
                                                effectiveRange: nil) as? UIFont {
            fontPointSize = font.pointSize
        }
        displayNewImageIfNeeded(
            desiredIconSize: desiredIconSize,
            fontPointSize: fontPointSize
        )
        if let image = self.image {
            return bounds(for: image)
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
        } else if !isLoadingMention {
            loadMention()
        }
    }
    
    private func loadMention() {
        isLoadingMention = true
        mentionService.loadMentions { [weak self] mentions in
            guard
                let mention = mentions.first(where: { $0.id == self?.pageId }),
                let self = self
            else {
                self?.isLoadingMention = false
                return
            }
            self.isLoadingMention = false
            self.icon = mention.objectIcon
            self.displayIcon(mention.objectIcon)
        }
    }
    
    private func displayIcon(_ iconImage: ObjectIconImage) {
        imageView.configure(
            model: .init(
                iconImage: iconImage,
                usecase: .mention(.body)
            )
        )
        
        imageView.imageView.image.flatMap {
            addLeadingSpaceAndDisplay($0)
        }
    }
    
    private func addLeadingSpaceAndDisplay(_ image: UIImage) {
        let imageWithSpaceSize = image.size + CGSize(width: Constants.iconLeadingSpace, height: 0)
        let imageWithSpace = image.imageDrawn(on: imageWithSpaceSize, offset: .zero)
        
        self.image = imageWithSpace
        bounds = bounds(for: imageWithSpace)
        
        updateAttachmentLayout()
    }
    
    private func bounds(for image: UIImage) -> CGRect {
        CGRect(origin: CGPoint(x: 0, y: -Constants.iconTopOffset), size: image.size)
    }
    
    private func updateAttachmentLayout() {
        DispatchQueue.main.async {
            guard let range = self.layoutManager?.rangeForAttachment(attachment: self) else { return }
            
            self.layoutManager?.invalidateLayout(forCharacterRange: range, actualCharacterRange: nil)
        }
    }
}

private extension MentionAttachment {
    
    enum Constants {
        static let defaultIconSize = CGSize(width: 20, height: 20)
        static let iconLeadingSpace: CGFloat = 3
        static let iconTopOffset: CGFloat = 3
    }
    
}
