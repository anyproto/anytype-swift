import Foundation
import ProtobufMessages
import AnytypeCore

public protocol BlockTableServiceProtocol {
    func createTable(
        contextId: BlockId,
        targetId: BlockId,
        position: BlockPosition,
        rowsCount: Int,
        columnsCount: Int
    ) async throws

    func rowListFill(
        contextId: BlockId,
        targetIds: [BlockId]
    ) async throws


    func insertColumn(contextId: BlockId, targetId: BlockId, position: BlockPosition) async throws
    func deleteColumn(contextId: BlockId, targetId: BlockId) async throws
    func columnDuplicate(contextId: BlockId, targetId: BlockId) async throws
    func columnSort(contextId: BlockId, columnId: BlockId, blocksSortType: BlocksSortType) async throws
    func columnMove(contextId: BlockId, targetId: BlockId, dropTargetID: BlockId, position: BlockPosition) async throws

    func insertRow(contextId: BlockId, targetId: BlockId, position: BlockPosition) async throws
    func deleteRow(contextId: BlockId, targetId: BlockId) async throws
    func rowDuplicate(contextId: BlockId, targetId: BlockId) async throws
    func rowMove(contextId: BlockId, targetId: BlockId, dropTargetID: BlockId, position: BlockPosition) async throws

    func clearContents(contextId: BlockId, blockIds: [BlockId]) async throws
    func clearStyle(contextId: BlockId, blocksIds: [BlockId]) async throws
}

public final class BlockTableService: BlockTableServiceProtocol {
    
    public init() {}
    
    // MARK: - BlockTableServiceProtocol
    
    public func createTable(
        contextId: BlockId,
        targetId: BlockId,
        position: BlockPosition,
        rowsCount: Int,
        columnsCount: Int
    ) async throws {
        try await ClientCommands.blockTableCreate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.position = position.asMiddleware
            $0.rows = UInt32(rowsCount)
            $0.columns = UInt32(columnsCount)
            $0.withHeaderRow = false
        }).invoke()
    }

    public func rowListFill(
        contextId: BlockId,
        targetIds: [BlockId]
    ) async throws {
        _ = try await ClientCommands.blockTableRowListFill(.with {
            $0.contextID = contextId
            $0.blockIds = targetIds
        }).invoke()
    }

    public func insertRow(contextId: BlockId, targetId: BlockId, position: BlockPosition) async throws {
        _ = try await ClientCommands.blockTableRowCreate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.position = position.asMiddleware
        }).invoke()
    }

    public func insertColumn(contextId: BlockId, targetId: BlockId, position: BlockPosition) async throws {
        _ = try await ClientCommands.blockTableColumnCreate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.position = position.asMiddleware
        }).invoke()
    }

    public func deleteColumn(contextId: BlockId, targetId: BlockId) async throws {
        _ = try await ClientCommands.blockTableColumnDelete(.with {
            $0.contextID = contextId
            $0.targetID = targetId
        }).invoke()
    }

    public func columnDuplicate(contextId: BlockId, targetId: BlockId) async throws {
        _ = try await ClientCommands.blockTableColumnDuplicate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.blockID = targetId
            $0.position = BlockPosition.left.asMiddleware
        }).invoke()
    }

    public func columnSort(contextId: BlockId, columnId: BlockId, blocksSortType: BlocksSortType) async throws {
        _ = try await ClientCommands.blockTableSort(.with {
            $0.contextID = contextId
            $0.columnID = columnId
            $0.type = blocksSortType.asMiddleware
        }).invoke()
    }

    public func columnMove(contextId: BlockId, targetId: BlockId, dropTargetID: BlockId, position: BlockPosition) async throws {
        _ = try await ClientCommands.blockTableColumnMove(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.dropTargetID = dropTargetID
            $0.position = position.asMiddleware
        }).invoke()
    }

    public func rowMove(contextId: BlockId, targetId: BlockId, dropTargetID: BlockId, position: BlockPosition) async throws {
        _ = try await ClientCommands.blockListMoveToExistingObject(.with {
            $0.contextID = contextId
            $0.blockIds = [targetId]
            $0.targetContextID = contextId
            $0.dropTargetID = dropTargetID
            $0.position = position.asMiddleware
        }).invoke()
    }

    public func deleteRow(contextId: BlockId, targetId: BlockId) async throws {
        _ = try await ClientCommands.blockTableRowDelete(.with {
            $0.contextID = contextId
            $0.targetID = targetId
        }).invoke()
    }

    public func rowDuplicate(contextId: BlockId, targetId: BlockId) async throws {
        _ = try await ClientCommands.blockTableRowDuplicate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.blockID = targetId
            $0.position = BlockPosition.bottom.asMiddleware
        }).invoke()
    }

    public func clearContents(contextId: BlockId, blockIds: [BlockId]) async throws {
        _ = try await ClientCommands.blockTextListClearContent(.with {
            $0.contextID = contextId
            $0.blockIds = blockIds
        }).invoke()
    }

    public func clearStyle(contextId: BlockId, blocksIds: [BlockId]) async throws {
        _ = try await ClientCommands.blockTextListClearStyle(.with {
            $0.contextID = contextId
            $0.blockIds = blocksIds
        }).invoke()
    }
}
