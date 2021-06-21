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
    private weak var layoutManager: NSLayoutManager?
    private let mentionService = MentionObjectsService(pageObjectsCount: 1)
    private var subscriptions = [AnyCancellable]()
    private var iconSize: CGSize?
    private var font: UIFont?
    private var imageProperty: ImageProperty?
    
    init(name: String, pageId: String) {
        self.pageId = pageId
        self.name = name
        super.init(data: nil, ofType: nil)
        mentionService.setFilterString(name)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attachmentBounds(for textContainer: NSTextContainer?,
                                   proposedLineFragment lineFrag: CGRect,
                                   glyphPosition position: CGPoint,
                                   characterIndex charIndex: Int) -> CGRect {
        iconSize = CGSize(width: lineFrag.height, height: lineFrag.height)
        layoutManager = textContainer?.layoutManager
        let attributedText = textContainer?.layoutManager?.textStorage
        // We want to get mention text font
        if let textLength = attributedText?.length, textLength > charIndex + 1 {
            font = attributedText?.attribute(.font,
                                             at: charIndex + 1,
                                             effectiveRange: nil) as? UIFont
        }
        if subscriptions.isEmpty {
            loadMention()
        }
        return super.attachmentBounds(for: textContainer,
                                      proposedLineFragment: lineFrag,
                                      glyphPosition: position,
                                      characterIndex: charIndex)
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
            self?.displayIcon(from: iconData)
        }
        subscriptions.append(subscription)
    }
    
    private func displayIcon(from iconData: DocumentIcon) {
        switch iconData {
        case let .emoji(emoji):
            guard let size = iconSize,
                  let font = font,
                  let image = emoji.value.image(contextSize: emojiSize(),
                                                imageSize: size,
                                                imageOffset: CGPoint(x: 0, y: 0),
                                                font: font) else { return }
            display(image)
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
            let imageWithSpaceSize = roundedImage.size + CGSize(width: Constants.iconLeadingSpace, height: 0)
            let imageWithSpace = roundedImage.imageDrawn(on: imageWithSpaceSize, offset: .zero)
            self?.display(imageWithSpace)
        }
        subscriptions.append(subscription)
        imageProperty = property
    }
    
    private func updateAttachmentLayout() {
        guard let range = layoutManager?.rangeForAttachment(attachment: self) else { return }
        layoutManager?.invalidateLayout(forCharacterRange: range, actualCharacterRange: nil)
    }
    
    private func display(_ image: UIImage) {
        self.image = image
        bounds = CGRect(origin: CGPoint(x: 0, y: -Constants.iconTopOffset), size: image.size)
        updateAttachmentLayout()
    }
    
    private func emojiSize() -> CGSize {
        let size = iconSize ?? Constants.defaultIconSize
        return size + CGSize(width: Constants.iconLeadingSpace, height: 0)
    }
}
