import Foundation
import Combine
import SwiftProtobuf
import BlocksModels
import ProtobufMessages
import AnytypeCore

enum ObjectActionsServiceError: Error {
    case nothingToUndo
    case nothingToRedo

    var message: String {
        switch self {
        case .nothingToUndo:
            return Loc.nothingToUndo
        case .nothingToRedo:
            return Loc.nothingToRedo
        }
    }
}


final class ObjectActionsService: ObjectActionsServiceProtocol {
    private var deleteSubscription: AnyCancellable?

    func delete(objectIds: [BlockId], completion: @escaping (Bool) -> ()) {
        AnytypeAnalytics.instance().logDeletion(count: objectIds.count)
        deleteSubscription = Anytype_Rpc.Object.ListDelete.Service
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
        _ = Anytype_Rpc.Object.ListSetIsArchived.Service.invoke(objectIds: objectIds, isArchived: isArchived)

        AnytypeAnalytics.instance().logMoveToBin(isArchived)
    }

    func setFavorite(objectId: BlockId, _ isFavorite: Bool) {
        _ = Anytype_Rpc.Object.SetIsFavorite.Service.invoke(contextID: objectId, isFavorite: isFavorite)

        AnytypeAnalytics.instance().logAddToFavorites(isFavorite)
    }

    func setLocked(_ isLocked: Bool, objectId: BlockId) {
        typealias ProtobufDictionary = [String: Google_Protobuf_Value]
        var protoFields = ProtobufDictionary()
        protoFields[BlockFieldBundledKey.isLocked.rawValue] = isLocked.protobufValue

        let protobufStruct: Google_Protobuf_Struct = .init(fields: protoFields)
        let blockField = Anytype_Rpc.Block.ListSetFields.Request.BlockField(
            blockID: objectId,
            fields: protobufStruct
        )

        _ = Anytype_Rpc.Block.ListSetFields.Service.invoke(
            contextID: objectId,
            blockFields: [blockField]
        ).map { EventsBunch(event: $0.event) }
        .getValue(domain: .objectActionsService)?
        .send()
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
        
        let response = Anytype_Rpc.BlockLink.CreateWithObject.Service
            .invoke(
                contextID: contextId, details: protobufStruct, templateID: templateId,
                targetID: targetId, position: position.asMiddleware, fields: .init()
            )
            .getValue(domain: .objectActionsService)
        
        guard let response = response else { return nil }

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
    
    func duplicate(objectId: BlockId) -> BlockId? {
        let result = Anytype_Rpc.Object.Duplicate.Service
            .invoke(contextID: objectId)
            .getValue(domain: .objectActionsService)
        return result?.id
    }

    // MARK: - ObjectActionsService / SetDetails
    
    func updateBundledDetails(contextID: BlockId, details: [BundledDetails]) {
        Anytype_Rpc.Object.SetDetails.Service.invoke(
            contextID: contextID,
            details: details.map {
                Anytype_Rpc.Object.SetDetails.Detail(
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
        AnytypeAnalytics.instance().logCreateObject(objectType: objectType, route: .turnInto)

        let response = Anytype_Rpc.Block.ListConvertToObjects.Service
            .invoke(
                contextID: contextID,
                blockIds: blocksIds,
                objectType: objectType
            )
            .getValue(domain: .objectActionsService)

        guard let response = response else { return nil }

        EventsBunch(event: response.event).send()

        return response.linkIds
    }
    
    func move(dashboadId: BlockId, blockId: BlockId, dropPositionblockId: BlockId, position: Anytype_Model_Block.Position) {
        Anytype_Rpc.Block.ListMoveToExistingObject.Service
            .invoke(
                contextID: dashboadId, blockIds: [blockId], targetContextID: dashboadId,
                dropTargetID: dropPositionblockId, position: position
            )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .objectActionsService)?
            .send()
    }
    
    func setObjectType(objectId: BlockId, objectTypeUrl: String) {
        let middlewareEvent = Anytype_Rpc.Object.SetObjectType.Service.invoke(
            contextID: objectId,
            objectTypeURL: objectTypeUrl
        )
            .map { (result) -> Anytype_ResponseEvent in
                AnytypeAnalytics.instance().logObjectTypeChange(objectTypeUrl)
                return result.event
            }
            .getValue(domain: .objectActionsService)


        let localEvent = LocalEvent.changeType(objectTypeURL: objectTypeUrl)

        EventsBunch(
            contextId: objectId,
            middlewareEvents: middlewareEvent?.messages ?? [],
            localEvents: [localEvent],
            dataSourceEvents: []
        ).send()
    }

    func applyTemplate(objectId: BlockId, templateId: BlockId) {
        let _ = Anytype_Rpc.Object.ApplyTemplate.Service.invoke(
            contextID: objectId,
            templateID: templateId
        )
    }

    func undo(objectId: BlockId) throws {
        let result = Anytype_Rpc.Object.Undo.Service
            .invoke(contextID: objectId)
            .map{ EventsBunch(event: $0.event).send() }

        switch result {
        case .success:
            break
        case .failure:
            throw ObjectActionsServiceError.nothingToUndo
        }
    }

    func redo(objectId: BlockId) throws {
        let result = Anytype_Rpc.Object.Redo.Service.invoke(contextID: objectId)
            .map { EventsBunch(event: $0.event).send() }

        switch result {
        case .success:
            break
        case .failure:
            throw ObjectActionsServiceError.nothingToRedo
        }
    }
}
