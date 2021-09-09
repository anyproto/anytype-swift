import BlocksModels
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
    private let selectionHandler: (MentionObject) -> Void
    
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
        
        guard let emoji = EmojiProvider.shared.randomEmoji()?.unicode,
              let iconEmoji = IconEmoji(emoji) else { return }
        
        
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
                objectIcon: .icon(.emoji(iconEmoji)),
                name: name,
                description: nil,
                type: nil
            )
            didSelectMention(mention)
        case let .failure(error):
            anytypeAssertionFailure(error.localizedDescription)
        }
    }
    
    private func obtainMentions() {
        service.loadMentions { [weak self] mentions in
            self?.view?.display(mentions.map { .mention($0) })
        }
    }
}
