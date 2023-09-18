import ProtobufMessages
import Services
import AnytypeCore
import SwiftProtobuf
import Foundation

final class MiddlewareEventConverter {
    private let infoContainer: InfoContainerProtocol
    private let relationLinksStorage: RelationLinksStorageProtocol
    private let detailsStorage: ObjectDetailsStorage
    private let restrictionsContainer: ObjectRestrictionsContainer
    
    private let informationCreator: BlockInformationCreator
    
    
    init(
        infoContainer: InfoContainerProtocol,
        relationLinksStorage: RelationLinksStorageProtocol,
        informationCreator: BlockInformationCreator,
        detailsStorage: ObjectDetailsStorage,
        restrictionsContainer: ObjectRestrictionsContainer
    ) {
        self.infoContainer = infoContainer
        self.relationLinksStorage = relationLinksStorage
        self.informationCreator = informationCreator
        self.detailsStorage = detailsStorage
        self.restrictionsContainer = restrictionsContainer
    }
    
    func convert(_ event: Anytype_Event.Message.OneOf_Value) -> DocumentUpdate? {
        switch event {
        case let .threadStatus(status):
            return SyncStatus(status.summary.status).flatMap { .syncStatus($0) }
        case let .blockSetFields(data):
            infoContainer.setFields(data: data)
            return .blocks(blockIds: [data.id])
        case let .blockAdd(data):
            infoContainer.add(data: data)
            // Because blockAdd message will always come together with blockSetChildrenIds
            // and it is easier to create update from those message
            return nil
        
        case let .blockDelete(data):
            infoContainer.delete(data: data)
            // Because blockDelete message will always come together with blockSetChildrenIds
            // and it is easier to create update from those message
            return nil
    
        case let .blockSetChildrenIds(data):
            infoContainer
                .setChildren(ids: data.childrenIds, parentId: data.id)
            return .general
        case let .blockSetText(newData):
            return blockSetTextUpdate(newData)
        case let .blockSetBackgroundColor(data):
            infoContainer.setBackgroundColor(data: data)
            
            var childIds = infoContainer.recursiveChildren(of: data.id).map { $0.id }
            childIds.append(data.id)
            return .blocks(blockIds: Set(childIds))
            
        case let .blockSetAlign(value):
            infoContainer.setAlign(data: value)

            let blockId = value.id
            let alignment = value.align
            guard let modelAlignment = alignment.asBlockModel else {
                anytypeAssertionFailure("We cannot parse alignment", info: ["value": "\(value)"])
                return .general
            }
            return .blocks(blockIds: [blockId])
        
        case let .objectDetailsSet(data):
            guard let details = detailsStorage.set(data: data) else { return nil }
            
            // if `type` deleted we should reload featured relations block
            if details.isDeleted {
                return .general
            }
            
            return .details(id: details.id)
            
        case let .objectDetailsAmend(data):
            let oldDetails = detailsStorage.get(id: data.id)
            
            guard let newDetails = detailsStorage.amend(data: data) else { return nil }

            guard let oldDetails = oldDetails else {
                return .details(id: data.id)
            }
            
            // change layout from `todo` to `basic` should trigger update title
            // in order to remove chackmark
            guard oldDetails.layout == newDetails.layout else {
                return .general
            }

            // if `type` changed we should reload featured relations block
            guard oldDetails.type == newDetails.type else {
                return .general
            }
            
            let relationKeys = data.details.map { $0.key }
            if relationLinksStorage.contains(relationKeys: relationKeys) {
                return .general
            }
            
            return .details(id: data.id)
            
        case let .objectDetailsUnset(data):
            guard let details = detailsStorage.unset(data: data) else { return nil }
            return .details(id: details.id)
            
        case .objectRelationsAmend(let data):
            relationLinksStorage.ammend(data: data)
            return .general
            
        case .objectRelationsRemove(let data):
            relationLinksStorage.remove(data: data)
            return .general
            
        case let .blockSetFile(data):
            infoContainer.setFile(data: data)
            
            guard data.hasState else {
                return .general
            }
            
            return .blocks(blockIds: [data.id])
        case let .blockSetBookmark(data):
            infoContainer.setBookmark(data: data)
            return .blocks(blockIds: [data.id])
            
        case let .blockSetDiv(data):
            infoContainer.setDiv(data: data)
            
            guard data.hasStyle else {
                return .general
            }
            
            return .blocks(blockIds: [data.id])
        case .blockSetLink(let data):
            infoContainer.setLink(data: data)
            return .blocks(blockIds: [data.id])
            
        //MARK: - Dataview
        case .blockDataviewViewSet(let data):
            infoContainer.dataviewViewSet(data: data)
            return .general
        case .blockDataviewViewOrder(let data):
            infoContainer.dataviewViewOrder(data: data)
            return .general
        case .blockDataviewViewDelete(let data):
            infoContainer.dataviewViewDelete(data: data)
            return .general
        case .blockDataviewRelationDelete(let data):
            infoContainer.dataviewRelationDelete(data: data)
            return .general
        case .blockDataviewRelationSet(let data):
            infoContainer.dataviewRelationSet(data: data)
            return .general
        case .blockDataViewGroupOrderUpdate(let data):
            infoContainer.dataViewGroupOrderUpdate(data: data)
            return .general
        case .blockDataViewObjectOrderUpdate(let data):
            infoContainer.dataViewObjectOrderUpdate(data: data)
            return .general
        case .blockDataviewTargetObjectIDSet(let data):
            infoContainer.dataviewTargetObjectIDSet(data: data)
            return .general
        case .blockDataviewIsCollectionSet(let data):
            infoContainer.dataviewIsCollectionSet(data: data)
            return .general
        case .blockDataviewViewUpdate(let data):
            infoContainer.dataviewViewUpdate(data: data)
            return .general
        case .blockSetRelation(let data):
            infoContainer.setRelation(data: data)
            return .general // Relace to `.blocks(blockIds: [data.id])` after implment task https://linear.app/anytype/issue/IOS-914
        case .objectRestrictionsSet(let restrictions):
            restrictionsContainer.set(data: restrictions)
            return nil
        case .blockSetWidget(let data):
            infoContainer.setWidget(data: data)
            return .general
        case .accountShow,
                .accountUpdate, // Event not working on middleware. See AccountManager.
                .accountDetails, // Skipped
                .accountConfigUpdate, // Remote config updates
                .objectRemove, // Remove from History Object wich was deleted. For Desktop purposes
                .subscriptionAdd, // Implemented in `SubscriptionsService`
                .subscriptionRemove, // Implemented in `SubscriptionsService`
                .subscriptionPosition, // Implemented in `SubscriptionsService`
                .subscriptionCounters, // Implemented in `SubscriptionsService`
                .subscriptionGroups, // Implemented in `GroupsSubscriptionsHandler`
                .blockDataviewSourceSet, // will be deleted on middle soon
                .filesUpload,
                .marksInfo,
                .blockSetRestrictions,
                .blockSetLatex,
                .blockSetVerticalAlign,
                .blockSetTableRow,
                .blockDataviewOldRelationSet,
                .blockDataviewOldRelationDelete,
                .userBlockJoin,
                .userBlockLeft,
                .userBlockSelectRange,
                .userBlockTextRange,
                .ping,
                .processNew,
                .processUpdate,
                .processDone,
                .fileLimitReached,
                .fileSpaceUsage,
                .fileLocalUsage:
            return nil
        }
    }
    
    private func blockSetTextUpdate(_ newData: Anytype_Event.Block.Set.Text) -> DocumentUpdate {
        guard let info = infoContainer.get(id: newData.id) else {
            anytypeAssertionFailure("Block model not found in container", info: ["id": newData.id])
            return .general
        }
        guard case let .text(oldText) = info.content else {
            anytypeAssertionFailure("Block model doesn't support text", info: ["contentType": "\(info.content.type)"])
            return .general
        }
        
        guard let newInformation = informationCreator.createBlockInformation(from: newData),
              case let .text(textContent) = newInformation.content else {
            return .general
        }
        infoContainer.add(newInformation)
        
        // If toggle changed style to another style or vice versa
        // we should rebuild all view to display/hide toggle's child blocks
        let isOldStyleToggle = oldText.contentType == .toggle
        let isNewStyleToggle = textContent.contentType == .toggle
        let toggleStyleChanged = isOldStyleToggle != isNewStyleToggle


        var childIds = infoContainer.recursiveChildren(of: newData.id).map { $0.id }
        childIds.append(newData.id)

        return toggleStyleChanged ? .general : .blocks(blockIds: Set(childIds))
    }
}
