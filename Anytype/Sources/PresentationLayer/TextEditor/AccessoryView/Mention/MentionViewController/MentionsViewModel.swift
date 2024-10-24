import Services
import ProtobufMessages
import SwiftProtobuf
import UIKit
import AnytypeCore
import Combine

final class MentionsViewModel {
    @Published private(set) var mentions = [MentionDisplayData]()
    let dismissSubject = PassthroughSubject<Void, Never>()
    
    var onSelect: RoutingAction<MentionObject>?
    
    private let document: any BaseDocumentProtocol
    @Injected(\.mentionObjectsService)
    private var mentionService: any MentionObjectsServiceProtocol
    @Injected(\.defaultObjectCreationService)
    private var defaultObjectService: any DefaultObjectCreationServiceProtocol
    private var searchTask: Task<(), any Error>?
    var searchString = ""
    
    init(document: some BaseDocumentProtocol) {
        self.document = document
    }
    
    func obtainMentions(filterString: String) {
        searchString = filterString
        searchTask?.cancel()
        searchTask = Task { @MainActor [weak self] in
            guard let self else { return }
            
            var updatedMentions: [MentionDisplayData] = []

            let dateMentions = FeatureFlags.dateAsAnObject ? try await mentionService.searchMentions(
                spaceId: document.spaceId,
                text: filterString,
                excludedObjectIds: [document.objectId],
                limitLayout: [.date]
            ) : []
            
            if dateMentions.isNotEmpty {
                updatedMentions.append(.header(title: Loc.dates))
                updatedMentions.append(contentsOf: dateMentions.map { .mention($0) })
            }
            
            let objectsMentions = try await mentionService.searchMentions(
                spaceId: document.spaceId,
                text: filterString,
                excludedObjectIds: [document.objectId],
                limitLayout: DetailsLayout.visibleLayoutsWithFiles - [.date]
            )
            
            if objectsMentions.isNotEmpty {
                updatedMentions.append(.header(title: Loc.objects))
                updatedMentions.append(contentsOf: objectsMentions.map { .mention($0) })
            }
            
            mentions = updatedMentions
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
