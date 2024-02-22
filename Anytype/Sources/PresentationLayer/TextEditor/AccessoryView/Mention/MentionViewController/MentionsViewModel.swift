import Services
import ProtobufMessages
import SwiftProtobuf
import UIKit
import Kingfisher
import AnytypeCore

final class MentionsViewModel {
    weak var view: MentionsView!
    
    private let document: BaseDocumentProtocol
    private let mentionService: MentionObjectsServiceProtocol
    private let defaultObjectService: DefaultObjectCreationServiceProtocol
    private let onSelect: (MentionObject) -> Void
    
    private var searchTask: Task<(), Error>?
    private var searchString = ""
    
    init(
        document: BaseDocumentProtocol,
        mentionService: MentionObjectsServiceProtocol,
        defaultObjectService: DefaultObjectCreationServiceProtocol,
        onSelect: @escaping (MentionObject) -> Void
    ) {
        self.document = document
        self.mentionService = mentionService
        self.defaultObjectService = defaultObjectService
        self.onSelect = onSelect
    }
    
    func obtainMentions(filterString: String) {
        searchString = filterString
        searchTask?.cancel()
        searchTask = Task { @MainActor in
            let mentions = try await mentionService.searchMentions(spaceId: document.spaceId, text: filterString, excludedObjectIds: [document.objectId])
            view?.display(mentions.map { .mention($0) }, newObjectName: filterString)
        }
    }
    
    func setFilterString(_ string: String) {
        obtainMentions(filterString: string)
    }
    
    func didSelectMention(_ mention: MentionObject) {
        onSelect(mention)
        view?.dismiss()
    }
    
    func didSelectCreateNewMention() {
        Task { @MainActor in
            guard let newBlockDetails = try? await defaultObjectService.createDefaultObject(name: searchString, shouldDeleteEmptyObject: false, spaceId: document.spaceId) else { return }
            
            AnytypeAnalytics.instance().logCreateObject(objectType: newBlockDetails.analyticsType, route: .mention)
            let name = searchString.isEmpty ? Loc.Object.Title.placeholder : searchString
            let mention = MentionObject(
                id: newBlockDetails.id,
                objectIcon: newBlockDetails.objectIconImage,
                name: name,
                description: nil,
                type: nil
            )
            didSelectMention(mention)
        }
    }
}
