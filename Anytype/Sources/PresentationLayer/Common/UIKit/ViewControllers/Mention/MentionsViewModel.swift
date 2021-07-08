import BlocksModels
import Combine
import ProtobufMessages
import SwiftProtobuf
import UIKit

final class MentionsViewModel {
    
    private enum Constants {
        static let defaultNewMentionName = "Untitled".localized
    }
    
    private let service: MentionObjectsService
    private weak var view: MentionsView?
    private var subscription: AnyCancellable?
    private var imageLoadingSubscriptions = [AnyCancellable]()
    private var imageStorage = [String: ImageProperty]()
    private let selectionHandler: (MentionObject) -> Void
    
    init(service: MentionObjectsService, selectionHandler: @escaping (MentionObject) -> Void) {
        self.service = service
        self.selectionHandler = selectionHandler
    }
    
    func setFilterString(_ string: String) {
        service.filterString = string
        imageLoadingSubscriptions.removeAll()
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
        let details = Google_Protobuf_Struct(fields: [DetailsKind.name.rawValue: nameValue,
                                                      DetailsKind.iconEmoji.rawValue: emojiValue])
        switch service.invoke(details: details) {
        case let .success(response):
            let mention = MentionObject(
                id: response.pageID,
                name: name,
                description: nil,
                iconData: DocumentIconType(emoji: emoji)
            )
            didSelectMention(mention)
        case let .failure(error):
            assertionFailure(error.localizedDescription)
        }
    }
    
    func image(for mention: MentionObject) -> UIImage? {
        if let imageProperty = imageStorage[mention.id] {
            return imageProperty.property
        }
        guard let icon = mention.iconData else { return nil }
        switch icon {
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
            case .placeholder:
                return nil
            }
        }
        return nil
    }
    
    private func loadImage(by id: String, mention: MentionObject) {
        let property = ImageProperty(imageId: id, ImageParameters(width: .thumbnail))
        let loadImage = property.stream.sink { [weak self] image in
            guard image != nil else { return }
            self?.view?.update(mention: .mention(mention))
        }
        imageLoadingSubscriptions.append(loadImage)
        imageStorage[mention.id] = property
    }
    
    private func obtainMentions() {
        subscription = service.obtainMentionsPublisher().sink(receiveCompletion: { result in
            switch result {
            case let .failure(error):
                assertionFailure(error.localizedDescription)
            case .finished:
                break
            }
        }) { [weak self] mentions in
            self?.view?.display(mentions.map { .mention($0) })
        }
    }
}
