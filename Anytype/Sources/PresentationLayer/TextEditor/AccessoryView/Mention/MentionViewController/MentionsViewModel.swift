import Services
import ProtobufMessages
import SwiftProtobuf
import UIKit
import AnytypeCore
import Combine

final class MentionsViewModel {
    @Published private(set) var mentions = ([MentionDisplayData](), "")
    @Published private(set) var newObjectName = ""
    let dismissSubject = PassthroughSubject<Void, Never>()
    
    var onSelect: RoutingAction<MentionObject>?
    
    private let document: BaseDocumentProtocol
    @Injected(\.mentionObjectsService)
    private var mentionService: MentionObjectsServiceProtocol
    @Injected(\.defaultObjectCreationService)
    private var defaultObjectService: DefaultObjectCreationServiceProtocol
    private var searchTask: Task<(), Error>?
    private var searchString = ""
    
    init(document: BaseDocumentProtocol) {
        self.document = document
    }
    
    func obtainMentions(filterString: String) {
        searchString = filterString
        searchTask?.cancel()
        searchTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let mentions = try await mentionService.searchMentions(
                spaceId: document.spaceId,
                text: filterString,
                excludedObjectIds: [document.objectId]
            )
            
            self.mentions = (mentions.map { .mention($0) }, filterString)
        }
    }
    
    func setFilterString(_ string: String) {
        obtainMentions(filterString: string)
    }
    
    func didSelectMention(_ mention: MentionObject) {
        onSelect?(mention)
        dismissSubject.send(())
    }
    
    func didSelectCreateNewMention() {
        Task { @MainActor in
            guard let newBlockDetails = try? await defaultObjectService.createDefaultObject(name: searchString, shouldDeleteEmptyObject: false, spaceId: document.spaceId) else { return }
            
            AnytypeAnalytics.instance().logCreateObject(objectType: newBlockDetails.analyticsType, spaceId: newBlockDetails.spaceId, route: .mention)
            let mention = MentionObject(details: newBlockDetails)
            didSelectMention(mention)
        }
    }
}
