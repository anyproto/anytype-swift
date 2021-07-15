import Combine
import UIKit

final class MentionAttachment: NSTextAttachment {
    
    private enum Constants {
        static let defaultIconSize = CGSize(width: 20, height: 20)
        static let iconLeadingSpace: CGFloat = 3
        static let iconTopOffset: CGFloat = 3
    }
    
    let pageId: String
    let name: String
    private var iconData: DocumentIconType?
    private weak var layoutManager: NSLayoutManager?
    private let mentionService = MentionObjectsService(pageObjectsCount: 1)
    private var subscriptions = [AnyCancellable]()
    private var iconSize: CGSize?
    private var fontPointSize: CGFloat?
    private var imageProperty: ImageProperty?
    
    init(name: String, pageId: String, iconData: DocumentIconType? = nil) {
        self.pageId = pageId
        self.name = name
        self.iconData = iconData
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
        let shouldCreateNewImage = storeParametersForIcon(size: desiredIconSize,
                                                          fontPointSize: fontPointSize)
        if !shouldCreateNewImage {
            return
        }
        if let iconData = iconData {
            displayIcon(from: iconData)
        } else if subscriptions.isEmpty {
            loadMention()
        }
    }
    
    private func loadMention() {
        let subscription = mentionService.obtainMentionsPublisher()
            .receiveOnMain()
            .sink { result in
            switch result {
            case let .failure(error):
                assertionFailure(error.localizedDescription)
            case .finished:
                break
            }
        } receiveValue: { [weak self] mentions in
            guard let mention = mentions.first,
                  let iconData = mention.iconData else { return }
            self?.iconData = iconData
            self?.displayIcon(from: iconData)
        }
        subscriptions.append(subscription)
    }
    
    private func displayIcon(from iconData: DocumentIconType) {
        switch iconData {
        case let .basic(basic):
            displayBasicIcon(basic)
        case let .profile(profile):
            displayProfileIcon(profile)
        }
    }
    
    private func displayProfileIcon(_ profileIcon: DocumentIconType.Profile) {
        switch profileIcon {
        case let .imageId(id):
            loadImage(imageId: id)
        case let .placeholder(placeholder):
            loadPlaceholderImage(placehodler: placeholder)
        }
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
            color: .secondaryTextColor,
            textGuideline: placeholderGuideline
        )
        addLeadingSpaceAndDisplay(image)
    }
    
    private func displayBasicIcon(_ basicIcon: DocumentIconType.Basic) {
        switch basicIcon {
        case let .emoji(emoji):
            guard let fontSize = fontPointSize,
                  let image = emoji.value.image(fontPointSize: fontSize) else { return }
            let newSize = image.size + CGSize(width: Constants.iconLeadingSpace, height: 0)
            let resizedImage = image.imageDrawn(on: newSize,
                                                offset: .zero)
            display(resizedImage)
        case let .imageId(imageId):
            loadImage(imageId: imageId)
        }
    }
    
    private func loadImage(imageId: String) {
        let property = ImageProperty(imageId: imageId, ImageParameters(width: .thumbnail))
        let subscription = property.stream.sink { [weak self] image in
            guard let image = image else { return }
            let scaledImage = image.scaled(to: self?.iconSize ?? Constants.defaultIconSize)
            let roundedImage = scaledImage.rounded(radius: min(scaledImage.size.height, scaledImage.size.width)/2)
            self?.addLeadingSpaceAndDisplay(roundedImage)
        }
        subscriptions.append(subscription)
        imageProperty = property
    }
    
    private func addLeadingSpaceAndDisplay(_ image: UIImage) {
        let imageWithSpaceSize = image.size + CGSize(width: Constants.iconLeadingSpace, height: 0)
        let imageWithSpace = image.imageDrawn(on: imageWithSpaceSize, offset: .zero)
        display(imageWithSpace)
    }
    
    private func updateAttachmentLayout() {
        DispatchQueue.main.async {
            guard let range = self.layoutManager?.rangeForAttachment(attachment: self) else { return }
            self.layoutManager?.invalidateLayout(forCharacterRange: range, actualCharacterRange: nil)
        }
    }
    
    private func display(_ image: UIImage) {
        self.image = image
        bounds = bounds(for: image)
        updateAttachmentLayout()
    }
    
    private func bounds(for image: UIImage) -> CGRect {
        CGRect(origin: CGPoint(x: 0, y: -Constants.iconTopOffset), size: image.size)
    }
}
