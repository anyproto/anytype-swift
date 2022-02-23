import Foundation
import Combine
import SwiftProtobuf
import BlocksModels
import ProtobufMessages
import Amplitude
import AnytypeCore


final class ObjectActionsService: ObjectActionsServiceProtocol {
    private var deleteSubscription: AnyCancellable?

    func delete(objectIds: [BlockId], completion: @escaping (Bool) -> ()) {
        Amplitude.instance().logDeletion(count: objectIds.count)
        
        deleteSubscription = Anytype_Rpc.ObjectList.Delete.Service
            .invoke(objectIds: objectIds, queue: DispatchQueue.global(qos: .userInitiated))
            .receiveOnMain()
            .sinkWithResult { result in
                switch result {
                case .success:
                    completion(true)
                case .failure(let error):
                    anytypeAssertionFailure("Deletion error: \(error)", domain: .objectActionsService)
                    completion(false)
                }
            }
    }
    
    func setArchive(objectId: BlockId, _ isArchived: Bool) {
        setArchive(objectIds: [objectId], isArchived)
    }
    
    func setArchive(objectIds: [BlockId], _ isArchived: Bool) {
        _ = Anytype_Rpc.ObjectList.Set.IsArchived.Service.invoke(objectIds: objectIds, isArchived: isArchived)

        Amplitude.instance().logMoveToBin(isArchived)
    }

    func setFavorite(objectId: BlockId, _ isFavorite: Bool) {
        _ = Anytype_Rpc.Object.SetIsFavorite.Service.invoke(contextID: objectId, isFavorite: isFavorite)

        Amplitude.instance().logAddToFavorites(isFavorite)
    }
    
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`.
    func createPage(
        contextId: BlockId,
        targetId: BlockId,
        details: [BundledDetails],
        position: BlockPosition,
        templateId: String
    ) -> BlockId? {
        
        let protobufDetails = details.reduce([String: Google_Protobuf_Value]()) { result, detail in
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
            .getValue(domain: .objectActionsService)
        
        guard let response = response else { return nil}

        let type = details.first(applying: { item -> String? in
            if case let .type(type) = item {
                return type.rawValue
            }
            return nil
        })

        Amplitude.instance().logCreateObject(objectType: type ?? "")

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
            .getValue(domain: .objectActionsService)?
            .send()
    }

    // MARK: - ObjectActionsService / SetDetails
    
    func updateBundledDetails(contextID: BlockId, details: [BundledDetails]) {
        Anytype_Rpc.Block.Set.Details.Service.invoke(
            contextID: contextID,
            details: details.map {
                Anytype_Rpc.Block.Set.Details.Detail(
                    key: $0.key,
                    value: $0.value
                )
            }
        )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .objectActionsService)?
            .send()
    }

    func convertChildrenToPages(contextID: BlockId, blocksIds: [BlockId], objectType: String) -> [BlockId]? {
        Amplitude.instance().logCreateObject(objectType: objectType)

        return Anytype_Rpc.BlockList.ConvertChildrenToPages.Service
            .invoke(contextID: contextID, blockIds: blocksIds, objectType: objectType)
            .map { $0.linkIds }
            .getValue(domain: .objectActionsService)
    }
    
    func move(dashboadId: BlockId, blockId: BlockId, dropPositionblockId: BlockId, position: Anytype_Model_Block.Position) {
        Anytype_Rpc.BlockList.Move.Service
            .invoke(
                contextID: dashboadId, blockIds: [blockId], targetContextID: dashboadId,
                dropTargetID: dropPositionblockId, position: position
            )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .objectActionsService)?
            .send()
    }
    
    func setObjectType(objectId: BlockId, objectTypeUrl: String) {
        Anytype_Rpc.Block.ObjectType.Set.Service.invoke(
            contextID: objectId,
            objectTypeURL: objectTypeUrl
        )
            .map { (result) -> EventsBunch in
                Amplitude.instance().logObjectTypeChange(objectTypeUrl)
                return EventsBunch(event: result.event)
            }
            .getValue(domain: .objectActionsService)?
            .send()
    }
    
}
