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
    
    func obtainMentions(filterString: String) {
        guard let mentions = mentionService.loadMentions() else { return }
        view?.display(mentions.map { .mention($0) }, newObjectName: filterString)
    }
    
    func setFilterString(_ string: String) {
        mentionService.filterString = string
        obtainMentions(filterString: string)

        AnytypeAnalytics.instance().logSearchQuery(.mention, length: string.count)
    }
    
    func didSelectMention(_ mention: MentionObject, index: Int) {
        onSelect(mention)
        view?.dismiss()

        AnytypeAnalytics.instance().logSearchResult(index: index + 1, length: mentionService.filterString.count)
    }
    
    func didSelectCreateNewMention() {
        guard let newBlockId = pageService.createPage(name: mentionService.filterString) else { return }

        AnytypeAnalytics.instance().logCreateObject(objectType: ObjectTypeProvider.shared.defaultObjectType.url, route: .mention)
        
        let name = mentionService.filterString.isEmpty ? Loc.untitled : mentionService.filterString
        let mention = MentionObject(
            id: newBlockId,
            objectIcon: .placeholder(name.first),
            name: name,
            description: nil,
            type: nil
        )
        didSelectMention(mention, index: 1)
    }
}
