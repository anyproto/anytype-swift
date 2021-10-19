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
        contextID: BlockId,
        targetID: BlockId,
        details: ObjectRawDetails,
        position: BlockPosition,
        templateID: String
    ) -> CreatePageResponse? {
        let convertedDetails = AnytypeDetailsConverter.convertObjectRawDetails(details) 
        let protobufDetails = convertedDetails.reduce([String: Google_Protobuf_Value]()) { result, detail in
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
    
    func setDetails(contextID: BlockId, details: ObjectRawDetails) -> MiddlewareResponse?  {
        let middlewareDetails = AnytypeDetailsConverter.convertObjectRawDetails(details) 
        let result = Anytype_Rpc.Block.Set.Details.Service.invoke(
            contextID: contextID,
            details: middlewareDetails
        ).map { MiddlewareResponse($0.event) }
        
        Amplitude.instance().logEvent(AmplitudeEventsName.blockSetDetails)
        
        return result.getValue()
    }
    
    private func setDetails(contextID: String, details: [Anytype_Rpc.Block.Set.Details.Detail]) -> AnyPublisher<MiddlewareResponse, Error> {
        Anytype_Rpc.Block.Set.Details.Service
            .invoke(contextID: contextID, details: details, queue: .global())
            .map(\.event)
            .map(MiddlewareResponse.init(_:))
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
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
