import Foundation
import Combine
import SwiftProtobuf
import BlocksModels
import ProtobufMessages
import Amplitude


enum ObjectActionsServicePossibleError: Error {
    case createPageActionPositionConversionHasFailed
}

/// Concrete service that adopts Object actions service.
/// NOTE: Use it as default service IF you want to use desired functionality.
final class ObjectActionsService: ObjectActionsServiceProtocol {
    // MARK: - ObjectActionsService / CreatePage
    /// Structure that adopts `CreatePage` action protocol
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`.
    func createPage(contextID: BlockId,
                    targetID: BlockId,
                    details: [DetailsKind: DetailsEntry<AnyHashable>],
                    position: BlockPosition,
                    templateID: String
    ) -> AnyPublisher<ServiceSuccess, Error> {
        guard let position = BlocksModelsParserCommonPositionConverter.asMiddleware(position) else {
            return Fail.init(error: ObjectActionsServicePossibleError.createPageActionPositionConversionHasFailed).eraseToAnyPublisher()
        }
        
        let convertedDetails = BlocksModelsDetailsConverter.asMiddleware(
            models: details
        )
        let preparedDetails = convertedDetails.map({($0.key, $0.value)})
        let protobufDetails: [String: Google_Protobuf_Value] = .init(preparedDetails) { (lhs, rhs) in rhs }
        let protobufStruct: Google_Protobuf_Struct = .init(fields: protobufDetails)
        
        return createPage(contextID: contextID, targetID: targetID, details: protobufStruct, position: position, templateID: templateID)
    }
    
    private func createPage(
        contextID: String,
        targetID: String,
        details: Google_Protobuf_Struct,
        position: Anytype_Model_Block.Position,
        templateID: String
    ) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.Block.CreatePage.Service.invoke(
            contextID: contextID, targetID: targetID, details: details, position: position, templateID: templateID
        )
        .map{ ServiceSuccess($0.event) }
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }

    // MARK: - ObjectActionsService / SetDetails
    func setDetails(contextID: BlockId, details: [DetailsKind: DetailsEntry<AnyHashable>]) -> AnyPublisher<ServiceSuccess, Error> {
        let middlewareDetails = BlocksModelsDetailsConverter.asMiddleware(models: details)
        return setDetails(contextID: contextID, details: middlewareDetails).handleEvents(receiveRequest:  {_ in
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.blockSetDetails)
        }).eraseToAnyPublisher()
    }
    
    private func setDetails(contextID: String, details: [Anytype_Rpc.Block.Set.Details.Detail]) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.Block.Set.Details.Service.invoke(contextID: contextID, details: details, queue: .global()).map(\.event).map(ServiceSuccess.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }

    /// Children to page
    /// - Parameters:
    ///   - contextID: document id
    ///   - blocksIds: blocks that will be converted to pages
    ///   - objectType: object type
    /// - Returns: AnyPublisher
    func convertChildrenToPages(contextID: BlockId, blocksIds: [BlockId], objectType: String) -> AnyPublisher<Void, Error> {
        Anytype_Rpc.BlockList.ConvertChildrenToPages.Service.invoke(contextID: contextID, blockIds: blocksIds, objectType: objectType).successToVoid().subscribe(on: DispatchQueue.global())
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
