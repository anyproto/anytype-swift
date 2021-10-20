import BlocksModels
import ProtobufMessages
import SwiftProtobuf
import UIKit
import Kingfisher
import AnytypeCore

final class MentionsViewModel {
    weak var view: MentionsView!
    
    private let mentionService: MentionObjectsService
    private let pageService: PageService
    private let onSelect: (MentionObject) -> Void
    
    init(
        mentionService: MentionObjectsService,
        pageService: PageService,
        onSelect: @escaping (MentionObject) -> Void
    ) {
        self.mentionService = mentionService
        self.pageService = pageService
        self.onSelect = onSelect
    }
    
    func obtainMentions() {
        guard let mentions = mentionService.loadMentions() else { return }
        view?.display(mentions.map { .mention($0) })
    }
    
    func setFilterString(_ string: String) {
        mentionService.filterString = string
        obtainMentions()
    }
    
    func didSelectMention(_ mention: MentionObject) {
        onSelect(mention)
        view?.dismiss()
    }
    
    func didSelectCreateNewMention() {
        let name = mentionService.filterString.isEmpty ? "Untitled".localized : mentionService.filterString
        guard let response = pageService.createPage(name: name) else { return }
        
        let mention = MentionObject(
            id: response.newBlockId,
            objectIcon: .placeholder(name.first),
            name: name,
            description: nil,
            type: nil
        )
        didSelectMention(mention)
    }
}
