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
    
    private let objectTypeProvider: ObjectTypeProviderProtocol
    
    init(objectTypeProvider: ObjectTypeProviderProtocol) {
        self.objectTypeProvider = objectTypeProvider
    }
    
    func delete(objectIds: [BlockId]) async throws {
        AnytypeAnalytics.instance().logDeletion(count: objectIds.count)
        
        try await ClientCommands.objectListDelete(.with {
            $0.objectIds = objectIds
        }).invoke(errorDomain: .objectActionsService)
    }
    
    func setArchive(objectIds: [BlockId], _ isArchived: Bool) {
        _ = try? ClientCommands.objectListSetIsArchived(.with {
            $0.objectIds = objectIds
            $0.isArchived = isArchived
        }).invoke(errorDomain: .objectActionsService)
        
        AnytypeAnalytics.instance().logMoveToBin(isArchived)
    }
    
    func setArchive(objectIds: [BlockId], _ isArchived: Bool) async throws {
        try await ClientCommands.objectListSetIsArchived(.with {
            $0.objectIds = objectIds
            $0.isArchived = isArchived
        }).invoke(errorDomain: .objectActionsService)
        
        AnytypeAnalytics.instance().logMoveToBin(isArchived)
    }
    
    func setFavorite(objectIds: [BlockId], _ isFavorite: Bool) {
        _ = try? ClientCommands.objectListSetIsFavorite(.with {
            $0.objectIds = objectIds
            $0.isFavorite = isFavorite
        }).invoke(errorDomain: .objectActionsService)
        
        AnytypeAnalytics.instance().logAddToFavorites(isFavorite)
    }
    
    func setFavorite(objectIds: [BlockId], _ isFavorite: Bool) async throws {
        try await ClientCommands.objectListSetIsFavorite(.with {
            $0.objectIds = objectIds
            $0.isFavorite = isFavorite
        }).invoke(errorDomain: .objectActionsService)
        
        AnytypeAnalytics.instance().logAddToFavorites(isFavorite)
    }

    func setLocked(_ isLocked: Bool, objectId: BlockId) {
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

        _ = try? ClientCommands.blockListSetFields(.with {
            $0.contextID = objectId
            $0.blockFields = [blockField]
        }).invoke(errorDomain: .objectActionsService)
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
        
        let response = try? ClientCommands.blockLinkCreateWithObject(.with {
            $0.contextID = contextId
            $0.details = protobufStruct
            $0.templateID = templateId
            $0.targetID = targetId
            $0.position = position.asMiddleware
        }).invoke(errorDomain: .objectActionsService)
        
        return response?.targetID
    }

    func updateLayout(contextID: BlockId, value: Int) {
        guard let selectedLayout = Anytype_Model_ObjectType.Layout(rawValue: value) else {
            return
        }
        _ = try? ClientCommands.objectSetLayout(.with {
            $0.contextID = contextID
            $0.layout = selectedLayout
        }).invoke(errorDomain: .objectActionsService)
    }
    
    func duplicate(objectId: BlockId) -> BlockId? {
        AnytypeAnalytics.instance().logDuplicateObject()
        let result = try? ClientCommands.objectDuplicate(.with {
            $0.contextID = objectId
        }).invoke(errorDomain: .objectActionsService)
        
        return result?.id
    }

    // MARK: - ObjectActionsService / SetDetails
    
    func updateBundledDetails(contextID: BlockId, details: [BundledDetails]) {
        _ = try? ClientCommands.objectSetDetails(.with {
            $0.contextID = contextID
            $0.details = details.map { details in
                Anytype_Rpc.Object.SetDetails.Detail.with {
                    $0.key = details.key
                    $0.value = details.value
                }
            }
        }).invoke(errorDomain: .objectActionsService)
    }
    
    func updateBundledDetails(contextID: BlockId, details: [BundledDetails]) async throws {
        try await ClientCommands.objectSetDetails(.with {
            $0.contextID = contextID
            $0.details = details.map { details in
                Anytype_Rpc.Object.SetDetails.Detail.with {
                    $0.key = details.key
                    $0.value = details.value
                }
            }
        }).invoke(errorDomain: .objectActionsService)
    }
    
    func updateDetails(contextId: String, relationKey: String, value: DataviewGroupValue) {
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
            anytypeAssertionFailure("DataviewGroupValue doesnt support", domain: .objectActionsService)
            return
        }
        
        _ = try? ClientCommands.objectSetDetails(.with {
            $0.contextID = contextId
            $0.details = [
                Anytype_Rpc.Object.SetDetails.Detail.with {
                    $0.key = relationKey
                    $0.value = protobufValue
                }
            ]
        }).invoke(errorDomain: .relationsService)
    }

    func convertChildrenToPages(contextID: BlockId, blocksIds: [BlockId], typeId: String) -> [BlockId]? {
        let type = objectTypeProvider.objectType(id: typeId)?.analyticsType ?? .object(typeId: typeId)
        AnytypeAnalytics.instance().logCreateObject(objectType: type, route: .turnInto)

        let response = try? ClientCommands.blockListConvertToObjects(.with {
            $0.contextID = contextID
            $0.blockIds = blocksIds
            $0.objectType = typeId
        }).invoke(errorDomain: .objectActionsService)
        
        return response?.linkIds
    }
    
    func move(dashboadId: BlockId, blockId: BlockId, dropPositionblockId: BlockId, position: Anytype_Model_Block.Position) {
        _ = try? ClientCommands.blockListMoveToExistingObject(.with {
            $0.contextID = dashboadId
            $0.blockIds = [blockId]
            $0.targetContextID = dashboadId
            $0.dropTargetID = dropPositionblockId
            $0.position = position
        }).invoke(errorDomain: .objectActionsService)
    }
    
    func move(dashboadId: BlockId, blockId: BlockId, dropPositionblockId: BlockId, position: Anytype_Model_Block.Position) async throws {
        try await ClientCommands.blockListMoveToExistingObject(.with {
            $0.contextID = dashboadId
            $0.blockIds = [blockId]
            $0.targetContextID = dashboadId
            $0.dropTargetID = dropPositionblockId
            $0.position = position
        }).invoke(errorDomain: .objectActionsService)
    }
    
    func setObjectType(objectId: BlockId, objectTypeId: String) {
        _ = try? ClientCommands.objectSetObjectType(.with {
            $0.contextID = objectId
            $0.objectTypeURL = objectTypeId
        }).invoke(errorDomain: .objectActionsService)
        
        let objectType = objectTypeProvider.objectType(id: objectTypeId)?.analyticsType ?? .object(typeId: objectTypeId)
        AnytypeAnalytics.instance().logObjectTypeChange(objectType)
    }

    func setObjectSetType(objectId: BlockId) async throws {
        try await ClientCommands.objectToSet(.with {
            $0.contextID = objectId
        }).invoke(errorDomain: .objectActionsService)
    }
    
    func addObjectsToCollection(contextId: BlockId, objectIds: [String]) async throws {
        try await ClientCommands.objectCollectionAdd(.with {
            $0.contextID = contextId
            $0.objectIds = objectIds
        }).invoke(errorDomain: .objectActionsService)
    }
    
    func setObjectCollectionType(objectId: BlockId) async throws {
        try await ClientCommands.objectToCollection(.with {
            $0.contextID = objectId
        }).invoke(errorDomain: .objectActionsService)
    }

    func applyTemplate(objectId: BlockId, templateId: BlockId) {
        _ = try? ClientCommands.objectApplyTemplate(.with {
            $0.contextID = objectId
            $0.templateID = templateId
        }).invoke(errorDomain: .objectActionsService)
    }
    
    func setSource(objectId: BlockId, source: [String]) async throws {
        try await ClientCommands.objectSetSource(.with {
            $0.contextID = objectId
            $0.source = source
        }).invoke(errorDomain: .objectActionsService)
    }

    func undo(objectId: BlockId) throws {
        do {
            _ = try ClientCommands.objectUndo(.with {
                $0.contextID = objectId
            }).invoke()
        } catch {
            throw ObjectActionsServiceError.nothingToUndo
        }
    }

    func redo(objectId: BlockId) throws {
        do {
            _ = try ClientCommands.objectRedo(.with {
                $0.contextID = objectId
            }).invoke()
        } catch {
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
        }).invoke(errorDomain: .objectActionsService)
    }
}
