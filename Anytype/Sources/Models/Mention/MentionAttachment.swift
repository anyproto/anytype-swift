import Combine
import UIKit
import Kingfisher
import AnytypeCore
import BlocksModels

final class MentionAttachment: NSTextAttachment {
    
    let pageId: BlockId
    let name: String
    let type: ObjectType?
    
    private weak var layoutManager: NSLayoutManager?
    
    private let mentionService = MentionObjectsService()
    
    private var icon: MentionIcon?
    private var iconSize: CGSize?
    private var fontPointSize: CGFloat?
    
    private var subscriptions = [AnyCancellable]()
    
    init(name: String, pageId: String, type: ObjectType?, icon: MentionIcon? = nil) {
        self.pageId = pageId
        self.name = name
        self.type = type
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
        } else if subscriptions.isEmpty {
            loadMention()
        }
    }
    
    private func loadMention() {
        mentionService.obtainMentionsPublisher()
            .receiveOnMain()
            .sink { result in
                switch result {
                case let .failure(error):
                    anytypeAssertionFailure(error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] mentions in
                guard
                    let mention = mentions.first(where: { $0.id == self?.pageId }),
                    let icon = mention.icon,
                    let self = self
                else { return }
                
                self.icon = icon
                self.displayIcon(icon)
            }
            .store(in: &subscriptions)
    }
    
    private func displayIcon(_ icon: MentionIcon) {
        switch icon {
        case let .objectIcon(objectIcon):
            switch objectIcon {
            case let .basic(basic):
                displayBasicIcon(basic)
            case let .profile(profile):
                displayProfileIcon(profile)
            }
        case let .checkmark(isChecked):
            displayCheckmarkIcon(isChecked: isChecked)
        }
    }
    
    private func displayBasicIcon(_ basicIcon: DocumentIconType.Basic) {
        switch basicIcon {
        case let .emoji(emoji):
            guard
                let fontSize = fontPointSize,
                let image = emoji.value.image(fontPointSize: fontSize)
            else { return }
            
            let newSize = image.size + CGSize(width: Constants.iconLeadingSpace, height: 0)
            let resizedImage = image.imageDrawn(on: newSize, offset: .zero)
            
            display(resizedImage)
        case let .imageId(imageId):
            loadImage(imageId: imageId, isBasicLayout: true)
        }
    }
    
    private func displayProfileIcon(_ profileIcon: DocumentIconType.Profile) {
        switch profileIcon {
        case let .imageId(id):
            loadImage(imageId: id, isBasicLayout: false)
        case let .placeholder(placeholder):
            loadPlaceholderImage(placehodler: placeholder)
        }
    }
    
    private func displayCheckmarkIcon(isChecked: Bool) {
        let image = isChecked ? UIImage.Title.TodoLayout.checkmark : UIImage.Title.TodoLayout.checkbox
        
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
        let placeholderGuideline = PlaceholderImageTextGuideline(
            text: String(placehodler),
            font: UIFont.systemFont(ofSize: fontPointSize ?? 0)
        )
        let image = PlaceholderImageBuilder.placeholder(
            with: imageGuideline,
            color: .grayscale30,
            textGuideline: placeholderGuideline
        )
        addLeadingSpaceAndDisplay(image)
    }
    
    private func loadImage(imageId: String, isBasicLayout: Bool) {
        guard let url = UrlResolver.resolvedUrl(.image(id: imageId, width: .thumbnail)) else { return }
        let imageSize = self.iconSize ?? Constants.defaultIconSize
        let cornerRadius = isBasicLayout ? 1 : min(imageSize.height, imageSize.width) / 2
        let processor = ResizingImageProcessor(referenceSize: imageSize, mode: .aspectFill)
            |> CroppingImageProcessor(size: imageSize)
            |> RoundCornerImageProcessor(radius: .point(cornerRadius))
        
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
