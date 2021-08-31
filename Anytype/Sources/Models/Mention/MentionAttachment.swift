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
    
    private var icon: MentionIcon?
    private var iconSize: CGSize?
    private var fontPointSize: CGFloat?
    
    private var isLoadingMention = false
    
    init(name: String, pageId: String, icon: MentionIcon? = nil) {
        self.pageId = pageId
        self.name = name
        self.icon = icon
        
        super.init(data: nil, ofType: nil)
        
        mentionService.filterString = name
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attachmentBounds(for textContainer: NSTextContainer?,
                                   proposedLineFragment lineFrag: CGRect,
                                   glyphPosition position: CGPoint,
                                   characterIndex charIndex: Int) -> CGRect {
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
        displayNewImageIfNeeded(desiredIconSize: desiredIconSize,
                                fontPointSize: fontPointSize)
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
                let icon = mention.icon,
                let self = self
            else {
                self?.isLoadingMention = false
                return
            }
            self.isLoadingMention = false
            self.icon = icon
            self.displayIcon(icon)
        }
    }
    
    private func displayIcon(_ icon: MentionIcon) {
        switch icon {
        case let .objectIcon(objectIcon):
            switch objectIcon {
            case let .basic(id):
                loadImage(imageId: id, isBasicLayout: true)
            case let .profile(profile):
                displayProfileIcon(profile)
            case let .emoji(emoji):
                guard
                    let fontSize = fontPointSize,
                    let image = emoji.value.image(fontPointSize: fontSize)
                else { return }
                
                let newSize = image.size + CGSize(width: Constants.iconLeadingSpace, height: 0)
                let resizedImage = image.imageDrawn(on: newSize, offset: .zero)
                
                display(resizedImage)
            }
        case let .checkmark(isChecked):
            displayCheckmarkIcon(isChecked: isChecked)
        }
    }
    
    private func displayProfileIcon(_ profileIcon: ObjectIconType.Profile) {
        switch profileIcon {
        case let .imageId(id):
            loadImage(imageId: id, isBasicLayout: false)
        case let .character(placeholder):
            loadPlaceholderImage(placehodler: placeholder)
        }
    }
    
    private func displayCheckmarkIcon(isChecked: Bool) {
        let image = isChecked ? UIImage.ObjectIcon.checkmark : UIImage.ObjectIcon.checkbox
        
        let size = iconSize ?? Constants.defaultIconSize
        
        addLeadingSpaceAndDisplay(image.scaled(to: size))
    }
    
    private func loadPlaceholderImage(placehodler: Character) {
        let size = iconSize ?? Constants.defaultIconSize
        let imageGuideline = ImageGuideline(
            size: size,
            cornerRadius: min(
                size.width,
                size.height
            ) / 2
        )
        
        var imageBuilder = ImageBuilder(imageGuideline)
            .setImageColor(.grayscale30)
            .setText(String(placehodler))
        if let fontPointSize = fontPointSize {
            imageBuilder = imageBuilder.setFont(UIFont.systemFont(ofSize: fontPointSize))
        }
        addLeadingSpaceAndDisplay(imageBuilder.build())
    }
    
    private func loadImage(imageId: String, isBasicLayout: Bool) {
        guard let url = ImageID(id: imageId).resolvedUrl else { return }
        let imageSize = self.iconSize ?? Constants.defaultIconSize
        let cornerRadius = isBasicLayout ? 1 : min(imageSize.height, imageSize.width) / 2
        let processor = KFProcessorBuilder(
            scalingType: .resizing(.aspectFill),
            targetSize: imageSize,
            cornerRadius: .point(cornerRadius)
        ).processor
        
        KingfisherManager.shared.retrieveImage(
            with: url,
            options: [.processor(processor)]
        ) { [weak self] result in
            guard case let .success(result) = result else { return }
            
            self?.addLeadingSpaceAndDisplay(result.image)
        }
    }
    
    private func addLeadingSpaceAndDisplay(_ image: UIImage) {
        let imageWithSpaceSize = image.size + CGSize(width: Constants.iconLeadingSpace, height: 0)
        let imageWithSpace = image.imageDrawn(on: imageWithSpaceSize, offset: .zero)
        display(imageWithSpace)
    }
    
    private func display(_ image: UIImage) {
        self.image = image
        bounds = bounds(for: image)
        
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
