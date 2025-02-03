import ProtobufMessages
import Services
import AnytypeCore
import SwiftProtobuf
import Foundation

final class MiddlewareEventConverter {
    private let infoContainer: any InfoContainerProtocol
    private let detailsStorage: ObjectDetailsStorage
    private let restrictionsContainer: ObjectRestrictionsContainer
    
    private let informationCreator: BlockInformationCreator
    
    init(
        infoContainer: some InfoContainerProtocol,
        informationCreator: BlockInformationCreator,
        detailsStorage: ObjectDetailsStorage,
        restrictionsContainer: ObjectRestrictionsContainer
    ) {
        self.infoContainer = infoContainer
        self.informationCreator = informationCreator
        self.detailsStorage = detailsStorage
        self.restrictionsContainer = restrictionsContainer
    }
    
    func convert(_ event: MiddlewareEventMessage.OneOf_Value) -> DocumentUpdate? {
        switch event {
        case let .blockSetFields(data):
            infoContainer.setFields(data: data)
            return .block(blockId: data.id)
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
            return .block(blockId: data.id)
        case let .blockSetText(newData):
            return blockSetTextUpdate(newData)
        case let .blockSetBackgroundColor(data):
            infoContainer.setBackgroundColor(data: data)
            return .block(blockId: data.id)
        case let .blockSetAlign(value):
            infoContainer.setAlign(data: value)
            return .block(blockId: value.id)
        
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
            
            return .details(id: data.id)
            
        case let .objectDetailsUnset(data):
            guard let details = detailsStorage.unset(data: data) else { return nil }
            return .details(id: details.id)
            
        case let .blockSetFile(data):
            infoContainer.setFile(data: data)
            
            guard data.hasState else {
                return .general
            }
            
            return .block(blockId: data.id)
        case let .blockSetBookmark(data):
            infoContainer.setBookmark(data: data)
            return .block(blockId: data.id)
            
        case let .blockSetDiv(data):
            infoContainer.setDiv(data: data)
            
            guard data.hasStyle else {
                return .general
            }
            
            return .block(blockId: data.id)
        case .blockSetLink(let data):
            infoContainer.setLink(data: data)
            return .block(blockId: data.id)
            
        //MARK: - Dataview
        case .blockDataviewViewSet(let data):
            infoContainer.dataviewViewSet(data: data)
            return .block(blockId: data.id)
        case .blockDataviewViewOrder(let data):
            infoContainer.dataviewViewOrder(data: data)
            return .block(blockId: data.id)
        case .blockDataviewViewDelete(let data):
            infoContainer.dataviewViewDelete(data: data)
            return .block(blockId: data.id)
        case .blockDataviewRelationDelete(let data):
            infoContainer.dataviewRelationDelete(data: data)
            return .block(blockId: data.id)
        case .blockDataviewRelationSet(let data):
            infoContainer.dataviewRelationSet(data: data)
            return .block(blockId: data.id)
        case .blockDataViewGroupOrderUpdate(let data):
            infoContainer.dataViewGroupOrderUpdate(data: data)
            return .block(blockId: data.id)
        case .blockDataViewObjectOrderUpdate(let data):
            infoContainer.dataViewObjectOrderUpdate(data: data)
            return .block(blockId: data.id)
        case .blockDataviewTargetObjectIDSet(let data):
            infoContainer.dataviewTargetObjectIDSet(data: data)
            return .block(blockId: data.id)
        case .blockDataviewIsCollectionSet(let data):
            infoContainer.dataviewIsCollectionSet(data: data)
            return .block(blockId: data.id)
        case .blockDataviewViewUpdate(let data):
            infoContainer.dataviewViewUpdate(data: data)
            return .block(blockId: data.id)
        case .blockSetRelation(let data):
            infoContainer.setRelation(data: data)
            return .general // Relace to `.blocks(blockIds: [data.id])` after implment task https://linear.app/anytype/issue/IOS-914
        case .objectRestrictionsSet(let restrictions):
            restrictionsContainer.set(data: restrictions)
            return nil
        case .blockSetWidget(let data):
            infoContainer.setWidget(data: data)
            return .block(blockId: data.id)
        case .objectClose:
            return .close
        case .accountShow,
                .threadStatus, // Legacy. See SyncStatusStorage
                .accountUpdate, // Event not working on middleware. See AccountManager.
                .accountDetails, // Skipped
                .accountConfigUpdate, // Remote config updates
                .accountLinkChallenge,
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
                .fileLocalUsage,
                .fileLimitUpdated,
                .notificationSend,
                .notificationUpdate,
                .payloadBroadcast,
                .importFinish,
                .spaceSyncStatusUpdate, // Implemented in `SyncStatusStorage`
                .p2PStatusUpdate, // Implemented in `P2PStatusStorage`
                .membershipUpdate, // Implemented in `MembershipStatusStorage`
                .chatAdd,
                .chatDelete,
                .chatUpdate,
                .chatUpdateReactions,
                .accountLinkChallengeHide,
                .objectRelationsAmend, // deprecated: will be removed in next release
                .objectRelationsRemove, // deprecated: will be removed in next release
                .accountLinkChallengeHide:
            return nil
        }
    }
    
    private func blockSetTextUpdate(_ newData: Anytype_Event.Block.Set.Text) -> DocumentUpdate? {
        guard let info = infoContainer.get(id: newData.id) else {
            anytypeAssertionFailure("Block model not found in container", info: ["id": newData.id])
            return nil
        }
        guard info.content.isText else {
            anytypeAssertionFailure("Block model doesn't support text", info: ["contentType": "\(info.content.type)"])
            return nil
        }
        
        guard let newInformation = informationCreator.createBlockInformation(from: newData),
              case .text = newInformation.content else {
            return nil
        }
        infoContainer.add(newInformation)

        return .block(blockId: newData.id)
    }
}
