import Foundation
import Services
import ProtobufMessages
import AnytypeCore

protocol BlockTableServiceProtocol {
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

final class BlockTableService: BlockTableServiceProtocol {
    func createTable(
        contextId: BlockId,
        targetId: BlockId,
        position: BlockPosition,
        rowsCount: Int,
        columnsCount: Int
    ) async throws {
        AnytypeAnalytics.instance().logCreateBlock(type: AnalyticsConstants.simpleTableBlock)
        try await ClientCommands.blockTableCreate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.position = position.asMiddleware
            $0.rows = UInt32(rowsCount)
            $0.columns = UInt32(columnsCount)
            $0.withHeaderRow = false
        }).invoke()
    }

    func rowListFill(
        contextId: BlockId,
        targetIds: [BlockId]
    ) async throws {
        _ = try await ClientCommands.blockTableRowListFill(.with {
            $0.contextID = contextId
            $0.blockIds = targetIds
        }).invoke()
    }

    func insertRow(contextId: BlockId, targetId: BlockId, position: BlockPosition) async throws {
        _ = try await ClientCommands.blockTableRowCreate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.position = position.asMiddleware
        }).invoke()
    }

    func insertColumn(contextId: BlockId, targetId: BlockId, position: BlockPosition) async throws {
        _ = try await ClientCommands.blockTableColumnCreate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.position = position.asMiddleware
        }).invoke()
    }

    func deleteColumn(contextId: BlockId, targetId: BlockId) async throws {
        _ = try await ClientCommands.blockTableColumnDelete(.with {
            $0.contextID = contextId
            $0.targetID = targetId
        }).invoke()
    }

    func columnDuplicate(contextId: BlockId, targetId: BlockId) async throws {
        _ = try await ClientCommands.blockTableColumnDuplicate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.blockID = targetId
            $0.position = BlockPosition.left.asMiddleware
        }).invoke()
    }

    func columnSort(contextId: BlockId, columnId: BlockId, blocksSortType: BlocksSortType) async throws {
        _ = try await ClientCommands.blockTableSort(.with {
            $0.contextID = contextId
            $0.columnID = columnId
            $0.type = blocksSortType.asMiddleware
        }).invoke()
    }

    func columnMove(contextId: BlockId, targetId: BlockId, dropTargetID: BlockId, position: BlockPosition) async throws {
        _ = try await ClientCommands.blockTableColumnMove(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.dropTargetID = dropTargetID
            $0.position = position.asMiddleware
        }).invoke()
    }

    func rowMove(contextId: BlockId, targetId: BlockId, dropTargetID: BlockId, position: BlockPosition) async throws {
        _ = try await ClientCommands.blockListMoveToExistingObject(.with {
            $0.contextID = contextId
            $0.blockIds = [targetId]
            $0.targetContextID = contextId
            $0.dropTargetID = dropTargetID
            $0.position = position.asMiddleware
        }).invoke()
    }

    func deleteRow(contextId: BlockId, targetId: BlockId) async throws {
        _ = try await ClientCommands.blockTableRowDelete(.with {
            $0.contextID = contextId
            $0.targetID = targetId
        }).invoke()
    }

    func rowDuplicate(contextId: BlockId, targetId: BlockId) async throws {
        _ = try await ClientCommands.blockTableRowDuplicate(.with {
            $0.contextID = contextId
            $0.targetID = targetId
            $0.blockID = targetId
            $0.position = BlockPosition.bottom.asMiddleware
        }).invoke()
    }

    func clearContents(contextId: BlockId, blockIds: [BlockId]) async throws {
        _ = try await ClientCommands.blockTextListClearContent(.with {
            $0.contextID = contextId
            $0.blockIds = blockIds
        }).invoke()
    }

    func clearStyle(contextId: BlockId, blocksIds: [BlockId]) async throws {
        _ = try await ClientCommands.blockTextListClearStyle(.with {
            $0.contextID = contextId
            $0.blockIds = blocksIds
        }).invoke()
    }
}

enum BlocksSortType {
    case asc
    case desc

    var asMiddleware: Anytype_Model_Block.Content.Dataview.Sort.TypeEnum {
        switch self {
        case .asc:
            return .asc
        case .desc:
            return .desc
        }
    }
}

private enum AnalyticsConstants {
    static let simpleTableBlock = "table"
}
