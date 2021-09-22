import Foundation
import Combine
import SwiftProtobuf
import BlocksModels
import ProtobufMessages
import Amplitude

enum CreatePageResult {
    case response(CreatePageResponse)
    case error(Error)
}

enum ObjectActionsServiceError: Error {
    case createPageActionPositionConversionHasFailed
}

/// Concrete service that adopts Object actions service.
/// NOTE: Use it as default service IF you want to use desired functionality.
final class ObjectActionsService: ObjectActionsServiceProtocol {
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`.
    func createPage(
        contextID: BlockId,
        targetID: BlockId,
        details: RawDetailsData,
        position: BlockPosition,
        templateID: String
    ) -> CreatePageResult {
        guard let position = BlocksModelsParserCommonPositionConverter.asMiddleware(position) else {
            return .error(ObjectActionsServiceError.createPageActionPositionConversionHasFailed)
        }
        
        let convertedDetails = BlocksModelsDetailsConverter.asMiddleware(models: details)
        let protobufDetails = convertedDetails.reduce([String: Google_Protobuf_Value]()) { result, detail in
            var result = result
            result[detail.key] = detail.value
            return result
        }
        let protobufStruct = Google_Protobuf_Struct(fields: protobufDetails)
        
        return createPage(contextID: contextID, targetID: targetID, details: protobufStruct, position: position, templateID: templateID)
    }
    
    private func createPage(
        contextID: String,
        targetID: String,
        details: Google_Protobuf_Struct,
        position: Anytype_Model_Block.Position,
        templateID: String
    ) -> CreatePageResult {
        let result = Anytype_Rpc.Block.CreatePage.Service.invoke(
            contextID: contextID, details: details, templateID: templateID,
            targetID: targetID, position: position, fields: .init()
        )
        
        switch result {
        case let .failure(error):
            return .error(error)
        case let .success(response):
            return .response(CreatePageResponse(response))
        }
    }

    // MARK: - ObjectActionsService / SetDetails
    func setDetails(contextID: BlockId, details: RawDetailsData) -> AnyPublisher<ResponseEvent, Error> {
        let middlewareDetails = BlocksModelsDetailsConverter.asMiddleware(models: details)
        return setDetails(contextID: contextID, details: middlewareDetails).handleEvents(receiveRequest:  {_ in
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.blockSetDetails)
        }).eraseToAnyPublisher()
    }
    
    private func setDetails(contextID: String, details: [Anytype_Rpc.Block.Set.Details.Detail]) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.Block.Set.Details.Service
            .invoke(contextID: contextID, details: details, queue: .global())
            .map(\.event)
            .map(ResponseEvent.init(_:))
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }

    func convertChildrenToPages(contextID: BlockId, blocksIds: [BlockId], objectType: String) -> AnyPublisher<[BlockId], Error> {
        Anytype_Rpc.BlockList.ConvertChildrenToPages.Service
            .invoke(contextID: contextID, blockIds: blocksIds, objectType: objectType)
            .map { $0.linkIds }
            .subscribe(on: DispatchQueue.global())
            .handleEvents(receiveRequest:  {_ in
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.blockListConvertChildrenToPages)
            })
            .eraseToAnyPublisher()
    }
    
    @discardableResult
    func move(dashboadId: BlockId, blockId: BlockId, dropPositionblockId: BlockId, position: Anytype_Model_Block.Position) -> AnyPublisher<Void, Error> {
        Anytype_Rpc.BlockList.Move.Service.invoke(
            contextID: dashboadId, blockIds: [blockId], targetContextID: dashboadId, dropTargetID: dropPositionblockId, position: position
        ).successToVoid().subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }
}
