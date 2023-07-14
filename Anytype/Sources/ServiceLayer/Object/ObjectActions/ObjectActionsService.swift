import Foundation
import Combine
import SwiftProtobuf
import Services
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
    
    private let objectTypeProvider: ObjectTypeProviderProtocol
    
    init(objectTypeProvider: ObjectTypeProviderProtocol) {
        self.objectTypeProvider = objectTypeProvider
    }
    
    func delete(objectIds: [BlockId], route: RemoveCompletelyRoute) async throws {
        AnytypeAnalytics.instance().logDeletion(count: objectIds.count, route: route)
        
        try await ClientCommands.objectListDelete(.with {
            $0.objectIds = objectIds
        }).invoke()
    }
    
    func setArchive(objectIds: [BlockId], _ isArchived: Bool) async throws {
        try await ClientCommands.objectListSetIsArchived(.with {
            $0.objectIds = objectIds
            $0.isArchived = isArchived
        }).invoke()
        
        AnytypeAnalytics.instance().logMoveToBin(isArchived)
    }
    
    func setFavorite(objectIds: [BlockId], _ isFavorite: Bool) async throws {
        try await ClientCommands.objectListSetIsFavorite(.with {
            $0.objectIds = objectIds
            $0.isFavorite = isFavorite
        }).invoke()
        
        AnytypeAnalytics.instance().logAddToFavorites(isFavorite)
    }

    func setLocked(_ isLocked: Bool, objectId: BlockId) async throws {
        if isLocked {
            AnytypeAnalytics.instance().logLockPage()
        } else {
            AnytypeAnalytics.instance().logUnlockPage()
        }
        typealias ProtobufDictionary = [String: Google_Protobuf_Value]
        var protoFields = ProtobufDictionary()
        protoFields[BlockFieldBundledKey.isLocked.rawValue] = isLocked.protobufValue

        let protobufStruct: Google_Protobuf_Struct = .init(fields: protoFields)
        let blockField = Anytype_Rpc.Block.ListSetFields.Request.BlockField.with {
            $0.blockID = objectId
            $0.fields = protobufStruct
        }

        try await ClientCommands.blockListSetFields(.with {
            $0.contextID = objectId
            $0.blockFields = [blockField]
        }).invoke()
    }
    
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`.
    func createPage(
        contextId: BlockId,
        targetId: BlockId,
        details: [BundledDetails],
        position: BlockPosition,
        templateId: String
    ) async throws -> BlockId {
        let protobufDetails = details.reduce([String: Google_Protobuf_Value]()) { result, detail in
            var result = result
            result[detail.key] = detail.value
            return result
        }
        let protobufStruct = Google_Protobuf_Struct(fields: protobufDetails)
        
        let response = try await ClientCommands.blockLinkCreateWithObject(.with {
            $0.contextID = contextId
            $0.details = protobufStruct
            $0.templateID = templateId
            $0.targetID = targetId
            $0.position = position.asMiddleware
        }).invoke()
        
        return response.targetID
    }

    func updateLayout(contextID: BlockId, value: Int) async throws  {
        guard let selectedLayout = Anytype_Model_ObjectType.Layout(rawValue: value) else {
            return
        }
        try await ClientCommands.objectSetLayout(.with {
            $0.contextID = contextID
            $0.layout = selectedLayout
        }).invoke()
    }
    
    func duplicate(objectId: BlockId) async throws -> BlockId {
        AnytypeAnalytics.instance().logDuplicateObject()
        let result = try await ClientCommands.objectDuplicate(.with {
            $0.contextID = objectId
        }).invoke()
        
        return result.id
    }

    // MARK: - ObjectActionsService / SetDetails
    func updateBundledDetails(contextID: BlockId, details: [BundledDetails]) async throws {
        try await ClientCommands.objectSetDetails(.with {
            $0.contextID = contextID
            $0.details = details.map { details in
                Anytype_Rpc.Object.SetDetails.Detail.with {
                    $0.key = details.key
                    $0.value = details.value
                }
            }
        }).invoke()
    }
    
    func updateDetails(contextId: String, relationKey: String, value: DataviewGroupValue) async throws {
        let protobufValue: Google_Protobuf_Value?
        switch value {
        case .tag(let tag):
            protobufValue = tag.ids.protobufValue
        case .status(let status):
            protobufValue = status.id.protobufValue
        case .checkbox(let checkbox):
            protobufValue = checkbox.checked.protobufValue
        default:
            protobufValue = nil
        }
        
        guard let protobufValue else {
            anytypeAssertionFailure("DataviewGroupValue doesnt support")
            return
        }
        
        _ = try await ClientCommands.objectSetDetails(.with {
            $0.contextID = contextId
            $0.details = [
                Anytype_Rpc.Object.SetDetails.Detail.with {
                    $0.key = relationKey
                    $0.value = protobufValue
                }
            ]
        }).invoke()
    }

    func convertChildrenToPages(contextID: BlockId, blocksIds: [BlockId], typeId: String) async throws -> [BlockId] {
        let type = objectTypeProvider.objectType(id: typeId)?.analyticsType ?? .object(typeId: typeId)
        AnytypeAnalytics.instance().logCreateObject(objectType: type, route: .turnInto)

        let response = try await ClientCommands.blockListConvertToObjects(.with {
            $0.contextID = contextID
            $0.blockIds = blocksIds
            $0.objectType = typeId
        }).invoke()
        
        return response.linkIds
    }
    
    func move(dashboadId: BlockId, blockId: BlockId, dropPositionblockId: BlockId, position: Anytype_Model_Block.Position) async throws {
        try await ClientCommands.blockListMoveToExistingObject(.with {
            $0.contextID = dashboadId
            $0.blockIds = [blockId]
            $0.targetContextID = dashboadId
            $0.dropTargetID = dropPositionblockId
            $0.position = position
        }).invoke()
    }
    
    func setObjectType(objectId: BlockId, objectTypeId: String) async throws {
        _ = try await ClientCommands.objectSetObjectType(.with {
            $0.contextID = objectId
            $0.objectTypeURL = objectTypeId
        }).invoke()
        
        let objectType = objectTypeProvider.objectType(id: objectTypeId)?.analyticsType ?? .object(typeId: objectTypeId)
        AnytypeAnalytics.instance().logObjectTypeChange(objectType)
    }

    func setObjectSetType(objectId: BlockId) async throws {
        try await ClientCommands.objectToSet(.with {
            $0.contextID = objectId
        }).invoke()
    }
    
    func addObjectsToCollection(contextId: BlockId, objectIds: [String]) async throws {
        try await ClientCommands.objectCollectionAdd(.with {
            $0.contextID = contextId
            $0.objectIds = objectIds
        }).invoke()
    }
    
    func setObjectCollectionType(objectId: BlockId) async throws {
        try await ClientCommands.objectToCollection(.with {
            $0.contextID = objectId
        }).invoke()
    }

    func applyTemplate(objectId: BlockId, templateId: BlockId) async throws {
        try await ClientCommands.objectApplyTemplate(.with {
            $0.contextID = objectId
            $0.templateID = templateId
        }).invoke()
    }
    
    func setSource(objectId: BlockId, source: [String]) async throws {
        try await ClientCommands.objectSetSource(.with {
            $0.contextID = objectId
            $0.source = source
        }).invoke()
    }

    func undo(objectId: BlockId) async throws {
        do {
            try await ClientCommands.objectUndo(.with {
                $0.contextID = objectId
            }).invoke()
        } catch let error as Anytype_Rpc.Object.Undo.Response.Error where error.code == .canNotMove {
            throw ObjectActionsServiceError.nothingToUndo
        }
    }

    func redo(objectId: BlockId) async throws {
        do {
            try await ClientCommands.objectRedo(.with {
                $0.contextID = objectId
            }).invoke()
        }  catch let error as Anytype_Rpc.Object.Redo.Response.Error where error.code == .canNotMove {
            throw ObjectActionsServiceError.nothingToRedo
        }
    }
    
    func setInternalFlags(contextId: BlockId, internalFlags: [Int]) async throws {
        let flags: [Anytype_Model_InternalFlag] = internalFlags.compactMap { flag in
            guard let value = Anytype_Model_InternalFlag.Value(rawValue: flag) else { return nil }
            return Anytype_Model_InternalFlag.with { $0.value = value }
        }
        try await ClientCommands.objectSetInternalFlags(.with {
            $0.contextID = contextId
            $0.internalFlags = flags
        }).invoke()
    }
}
