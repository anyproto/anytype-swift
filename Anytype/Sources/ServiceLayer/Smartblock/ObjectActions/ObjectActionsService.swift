import Foundation
import Combine
import SwiftProtobuf
import BlocksModels
import ProtobufMessages
import Amplitude
import AnytypeCore


final class ObjectActionsService: ObjectActionsServiceProtocol {
    func delete(objectIds: [BlockId]) {
        Amplitude.instance().logDeletion(count: objectIds.count)
        _ = Anytype_Rpc.ObjectList.Delete.Service.invoke(objectIds: objectIds)
    }
    
    func setArchive(objectId: BlockId, _ isArchived: Bool) {
        setArchive(objectIds: [objectId], isArchived)
    }
    
    func setArchive(objectIds: [BlockId], _ isArchived: Bool) {
        _ = Anytype_Rpc.ObjectList.Set.IsArchived.Service.invoke(objectIds: objectIds, isArchived: isArchived)
    }

    func setFavorite(objectId: BlockId, _ isFavorite: Bool) {
        _ = Anytype_Rpc.Object.SetIsFavorite.Service.invoke(contextID: objectId, isFavorite: isFavorite)
    }
    
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`.
    func createPage(
        contextId: BlockId,
        targetId: BlockId,
        details: ObjectRawDetails,
        position: BlockPosition,
        templateId: String
    ) -> BlockId? {
        let protobufDetails = details.asMiddleware.reduce([String: Google_Protobuf_Value]()) { result, detail in
            var result = result
            result[detail.key] = detail.value
            return result
        }
        let protobufStruct = Google_Protobuf_Struct(fields: protobufDetails)
        
        let response = Anytype_Rpc.Block.CreatePage.Service
            .invoke(
                contextID: contextId, details: protobufStruct, templateID: templateId,
                targetID: targetId, position: position.asMiddleware, fields: .init()
            )
            .getValue()
        
        guard let response = response else { return nil}
        EventsBunch(event: response.event).send()
        return response.targetID
    }

    func updateLayout(contextID: BlockId, value: Int) {
        guard let selectedLayout = Anytype_Model_ObjectType.Layout(rawValue: value) else {
            return
        }
        let _ = Anytype_Rpc.Object.SetLayout.Service.invoke(
            contextID: contextID,
            layout: selectedLayout
        ).map { EventsBunch(event: $0.event) }
            .getValue()?
            .send()
    }

    // MARK: - ObjectActionsService / SetDetails
    
    func updateDetails(contextID: BlockId, updates: [DetailsUpdate]) {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockSetDetails)

        Anytype_Rpc.Block.Set.Details.Service.invoke(
            contextID: contextID,
            details: updates.map {
                Anytype_Rpc.Block.Set.Details.Detail(
                    key: $0.key,
                    value: $0.value
                )
            }
        )
            .map { EventsBunch(event: $0.event) }
            .getValue()?
            .send()
    }
    
    func setDetails(contextID: BlockId, details: ObjectRawDetails) {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockSetDetails)

        Anytype_Rpc.Block.Set.Details.Service.invoke(contextID: contextID, details: details.asMiddleware)
            .map { EventsBunch(event: $0.event) }
            .getValue()?
            .send()
    }
    
    func setRelationValue(contextID: BlockId, key: String, value: Google_Protobuf_Value) {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockSetDetails)
        
        Anytype_Rpc.Block.Set.Details.Service.invoke(
            contextID: contextID,
            details: [
                Anytype_Rpc.Block.Set.Details.Detail(
                    key: key,
                    value: value
                )
            ]
        )
            .map { EventsBunch(event: $0.event) }
            .getValue()?
            .send()
    }

    func convertChildrenToPages(contextID: BlockId, blocksIds: [BlockId], objectType: String) -> [BlockId]? {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockListConvertChildrenToPages)
        return Anytype_Rpc.BlockList.ConvertChildrenToPages.Service
            .invoke(contextID: contextID, blockIds: blocksIds, objectType: objectType)
            .map { $0.linkIds }
            .getValue()
    }
    
    func move(dashboadId: BlockId, blockId: BlockId, dropPositionblockId: BlockId, position: Anytype_Model_Block.Position) {
        Anytype_Rpc.BlockList.Move.Service
            .invoke(
                contextID: dashboadId, blockIds: [blockId], targetContextID: dashboadId,
                dropTargetID: dropPositionblockId, position: position
            )
            .map { EventsBunch(event: $0.event) }
            .getValue()?
            .send()
    }
    
    func setObjectType(objectId: BlockId, objectTypeUrl: String) {
        Anytype_Rpc.Block.ObjectType.Set.Service.invoke(
            contextID: objectId,
            objectTypeURL: objectTypeUrl
        )
            .map { EventsBunch(event: $0.event) }
            .getValue()?
            .send()
    }
    
}
