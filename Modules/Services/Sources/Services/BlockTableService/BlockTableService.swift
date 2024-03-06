import Foundation
import ProtobufMessages
import AnytypeCore

public protocol BlockTableServiceProtocol {
    func createTable(
        contextId: String,
        targetId: String,
        position: BlockPosition,
        rowsCount: Int,
        columnsCount: Int
    ) async throws -> String

    func rowListFill(
        contextId: String,
        targetIds: [String]
    ) async throws


    func insertColumn(contextId: String, targetId: String, position: BlockPosition) async throws
    func deleteColumn(contextId: String, targetId: String) async throws
    func columnDuplicate(contextId: String, targetId: String) async throws
    func columnSort(contextId: String, columnId: String, blocksSortType: BlocksSortType) async throws
    func columnMove(contextId: String, targetId: String, dropTargetID: String, position: BlockPosition) async throws

    func insertRow(contextId: String, targetId: String, position: BlockPosition) async throws
    func deleteRow(contextId: String, targetId: String) async throws
    func rowDuplicate(contextId: String, targetId: String) async throws
    func rowMove(contextId: String, targetId: String, dropTargetID: String, position: BlockPosition) async throws

    func clearContents(contextId: String, blockIds: [String]) async throws
    func clearStyle(contextId: String, blocksIds: [String]) async throws
}

public final class BlockTableService: BlockTableServiceProtocol {
    
    public init() {}
    
    // MARK: - BlockTableServiceProtocol
    
    public func createTable(
        contextId: String,
        targetId: String,
        position: BlockPosition,
        rowsCount: Int,
        columnsCount: Int
    ) async throws -> String {
        let response = try await ClientCommands.blockTableCreate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.position = position.asMiddleware
            $0.rows = UInt32(rowsCount)
            $0.columns = UInt32(columnsCount)
            $0.withHeaderRow = false
        }).invoke()
        
        return response.blockID
    }

    public func rowListFill(
        contextId: String,
        targetIds: [String]
    ) async throws {
        _ = try await ClientCommands.blockTableRowListFill(.with {
            $0.contextID = contextId
            $0.blockIds = targetIds
        }).invoke()
    }

    public func insertRow(contextId: String, targetId: String, position: BlockPosition) async throws {
        _ = try await ClientCommands.blockTableRowCreate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.position = position.asMiddleware
        }).invoke()
    }

    public func insertColumn(contextId: String, targetId: String, position: BlockPosition) async throws {
        _ = try await ClientCommands.blockTableColumnCreate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.position = position.asMiddleware
        }).invoke()
    }

    public func deleteColumn(contextId: String, targetId: String) async throws {
        _ = try await ClientCommands.blockTableColumnDelete(.with {
            $0.contextID = contextId
            $0.targetID = targetId
        }).invoke()
    }

    public func columnDuplicate(contextId: String, targetId: String) async throws {
        _ = try await ClientCommands.blockTableColumnDuplicate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.blockID = targetId
            $0.position = BlockPosition.left.asMiddleware
        }).invoke()
    }

    public func columnSort(contextId: String, columnId: String, blocksSortType: BlocksSortType) async throws {
        _ = try await ClientCommands.blockTableSort(.with {
            $0.contextID = contextId
            $0.columnID = columnId
            $0.type = blocksSortType.asMiddleware
        }).invoke()
    }

    public func columnMove(contextId: String, targetId: String, dropTargetID: String, position: BlockPosition) async throws {
        _ = try await ClientCommands.blockTableColumnMove(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.dropTargetID = dropTargetID
            $0.position = position.asMiddleware
        }).invoke()
    }

    public func rowMove(contextId: String, targetId: String, dropTargetID: String, position: BlockPosition) async throws {
        _ = try await ClientCommands.blockListMoveToExistingObject(.with {
            $0.contextID = contextId
            $0.blockIds = [targetId]
            $0.targetContextID = contextId
            $0.dropTargetID = dropTargetID
            $0.position = position.asMiddleware
        }).invoke()
    }

    public func deleteRow(contextId: String, targetId: String) async throws {
        _ = try await ClientCommands.blockTableRowDelete(.with {
            $0.contextID = contextId
            $0.targetID = targetId
        }).invoke()
    }

    public func rowDuplicate(contextId: String, targetId: String) async throws {
        _ = try await ClientCommands.blockTableRowDuplicate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.blockID = targetId
            $0.position = BlockPosition.bottom.asMiddleware
        }).invoke()
    }

    public func clearContents(contextId: String, blockIds: [String]) async throws {
        _ = try await ClientCommands.blockTextListClearContent(.with {
            $0.contextID = contextId
            $0.blockIds = blockIds
        }).invoke()
    }

    public func clearStyle(contextId: String, blocksIds: [String]) async throws {
        _ = try await ClientCommands.blockTextListClearStyle(.with {
            $0.contextID = contextId
            $0.blockIds = blocksIds
        }).invoke()
    }
}
