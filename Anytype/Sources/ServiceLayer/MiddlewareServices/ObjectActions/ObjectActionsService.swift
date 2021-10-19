import Foundation
import Combine
import SwiftProtobuf
import BlocksModels
import ProtobufMessages
import Amplitude
import AnytypeCore


final class ObjectActionsService: ObjectActionsServiceProtocol {
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`.
    func createPage(
        contextID: BlockId,
        targetID: BlockId,
        details: ObjectRawDetails,
        position: BlockPosition,
        templateID: String
    ) -> CreatePageResponse? {
        let protobufDetails = details.asMiddleware.reduce([String: Google_Protobuf_Value]()) { result, detail in
            var result = result
            result[detail.key] = detail.value
            return result
        }
        let protobufStruct = Google_Protobuf_Struct(fields: protobufDetails)
        
        return createPage(contextID: contextID, targetID: targetID, details: protobufStruct, position: position.asMiddleware, templateID: templateID)
    }
    
    private func createPage(
        contextID: String,
        targetID: String,
        details: Google_Protobuf_Struct,
        position: Anytype_Model_Block.Position,
        templateID: String
    ) -> CreatePageResponse? {
        Anytype_Rpc.Block.CreatePage.Service.invoke(
            contextID: contextID, details: details, templateID: templateID,
            targetID: targetID, position: position, fields: .init()
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
    
    @discardableResult
    func move(dashboadId: BlockId, blockId: BlockId, dropPositionblockId: BlockId, position: Anytype_Model_Block.Position) -> MiddlewareResponse? {
        Anytype_Rpc.BlockList.Move.Service.invoke(
            contextID: dashboadId, blockIds: [blockId], targetContextID: dashboadId,
            dropTargetID: dropPositionblockId, position: position
        )
            .map { MiddlewareResponse($0.event) }
            .getValue()
    }
}
