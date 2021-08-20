import BlocksModels
import Combine
import ProtobufMessages
import SwiftProtobuf
import UIKit
import Kingfisher
import AnytypeCore

final class MentionsViewModel {
    
    private enum Constants {
        static let defaultNewMentionName = "Untitled".localized
    }
    
    private let service: MentionObjectsService
    private weak var view: MentionsView?
    private var subscription: AnyCancellable?
    private let selectionHandler: (MentionObject) -> Void
    private var imageStorage = [String: UIImage]()
    
    init(service: MentionObjectsService, selectionHandler: @escaping (MentionObject) -> Void) {
        self.service = service
        self.selectionHandler = selectionHandler
    }
    
    func setFilterString(_ string: String) {
        service.filterString = string
        obtainMentions()
    }
    
    func setup(with view: MentionsView) {
        self.view = view
        obtainMentions()
    }
    
    func didSelectMention(_ mention: MentionObject) {
        selectionHandler(mention)
        view?.dismiss()
    }
    
    func didSelectCreateNewMention() {
        let name = service.filterString.isEmpty ? Constants.defaultNewMentionName : service.filterString
        
        guard let emoji = EmojiProvider.shared.randomEmoji()?.unicode else { return }
        
        let service = Anytype_Rpc.Page.Create.Service.self
        let emojiValue = Google_Protobuf_Value(stringValue: emoji)
        let nameValue = Google_Protobuf_Value(stringValue: name)
        let details = Google_Protobuf_Struct(
            fields: [
                DetailsKind.name.rawValue: nameValue,
                DetailsKind.iconEmoji.rawValue: emojiValue
            ]
        )
        switch service.invoke(details: details) {
        case let .success(response):
            let mention = MentionObject(
                id: response.pageID,
                icon: MentionIcon(emoji: emoji),
                name: name,
                description: nil,
                type: nil
            )
            didSelectMention(mention)
        case let .failure(error):
            anytypeAssertionFailure(error.localizedDescription)
        }
    }
    
    func image(for mention: MentionObject, size: CGSize, radius: CGFloat) -> UIImage? {
        if let image = imageStorage[mention.id] {
            return image
        }
        
        guard let icon = mention.icon else { return nil }
        
        switch icon {
        case let .objectIcon(objectIcon):
            switch objectIcon {
            case let .basic(basic):
                switch basic {
                case .emoji:
                    return nil
                case let .imageId(id):
                    loadImage(by: id, mention: mention)
                }
            case let .profile(profile):
                switch profile {
                case let .imageId(id):
                    loadImage(by: id, mention: mention)
                case let .placeholder(character):
                    let imageGuideline = ImageGuideline(
                        size: size,
                        cornerRadius: radius
                    )
                    let placeholderGuideline = PlaceholderImageTextGuideline(
                        text: String(character),
                        font: UIFont.systemFont(ofSize: 28)
                    )
                    return PlaceholderImageBuilder.placeholder(
                        with: imageGuideline,
                        color: .grayscale30,
                        textGuideline: placeholderGuideline
                    )
                }
            }
        
        case let .checkmark(isChecked):
            return isChecked ? UIImage.Title.TodoLayout.checkmark : UIImage.Title.TodoLayout.checkbox
        }
        
        return nil
    }
    
    private func loadImage(by id: String, mention: MentionObject) {
        guard let url = UrlResolver.resolvedUrl(.image(id: id, width: .thumbnail)) else { return }
        let imageSize = CGSize(width: 40, height: 40)
        
        let processor = ResizingImageProcessor(referenceSize: imageSize, mode: .aspectFill)
            |> CroppingImageProcessor(size: imageSize)
        
        KingfisherManager.shared.retrieveImage(
            with: url,
            options: [.processor(processor)]
        ) { [weak self] result in
            guard
                case let .success(result) = result,
                let self = self
            else { return }
            
            self.imageStorage[mention.id] = result.image
            self.view?.update(mention: .mention(mention))
        }
    }
    
    private func obtainMentions() {
        subscription = service.obtainMentionsPublisher().sink(receiveCompletion: { result in
            switch result {
            case let .failure(error):
                anytypeAssertionFailure(error.localizedDescription)
            case .finished:
                break
            }
        }) { [weak self] mentions in
            self?.view?.display(mentions.map { .mention($0) })
        }
    }
}
