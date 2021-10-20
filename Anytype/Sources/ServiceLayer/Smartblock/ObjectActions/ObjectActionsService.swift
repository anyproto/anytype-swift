import Foundation
import Combine
import SwiftProtobuf
import BlocksModels
import ProtobufMessages
import Amplitude
import AnytypeCore


final class ObjectActionsService: ObjectActionsServiceProtocol {
    func setArchive(objectId: String, _ isArchived: Bool) {
        _ = Anytype_Rpc.Object.SetIsArchived.Service.invoke(contextID: objectId, isArchived: isArchived)
    }

    func setFavorite(objectId: String, _ isFavorite: Bool) {
        _ = Anytype_Rpc.Object.SetIsFavorite.Service.invoke(contextID: objectId, isFavorite: isFavorite)
    }
    
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`.
    func createPage(
        contextId: BlockId,
        targetId: BlockId,
        details: ObjectRawDetails,
        position: BlockPosition,
        templateId: String
    ) -> CreatePageResponse? {
        let protobufDetails = details.asMiddleware.reduce([String: Google_Protobuf_Value]()) { result, detail in
            var result = result
            result[detail.key] = detail.value
            return result
        }
        let protobufStruct = Google_Protobuf_Struct(fields: protobufDetails)
        
        return Anytype_Rpc.Block.CreatePage.Service
            .invoke(
                contextID: contextId, details: protobufStruct, templateID: templateId,
                targetID: targetId, position: position.asMiddleware, fields: .init()
            )
            .map { CreatePageResponse($0) }
            .getValue()
    }

    // MARK: - ObjectActionsService / SetDetails
    
    func setDetails(contextID: BlockId, details: ObjectRawDetails) {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockSetDetails)
        
        Anytype_Rpc.Block.Set.Details.Service.invoke(contextID: contextID, details: details.asMiddleware)
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
}
