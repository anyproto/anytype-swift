import Foundation
import BlocksModels
import ProtobufMessages

protocol BlockTableServiceProtocol {
    func createTable(
        contextId: BlockId,
        targetId: BlockId,
        position: BlockPosition,
        rowsCount: Int,
        columnsCount: Int
    )

    func rowListFill(
        contextId: BlockId,
        targetIds: [BlockId]
    )


    func insertColumn(contextId: BlockId, targetId: BlockId, position: BlockPosition)
    func deleteColumn(contextId: BlockId, targetId: BlockId)
    func columnDuplicate(contextId: BlockId, targetId: BlockId)
    func columnSort(contextId: BlockId, columnId: BlockId, blocksSortType: BlocksSortType)
    func columnMove(contextId: BlockId, targetId: BlockId, dropTargetID: BlockId, position: BlockPosition)

    func insertRow(contextId: BlockId, targetId: BlockId, position: BlockPosition)
    func deleteRow(contextId: BlockId, targetId: BlockId)
    func rowDuplicate(contextId: BlockId, targetId: BlockId)
    func rowMove(contextId: BlockId, targetId: BlockId, dropTargetID: BlockId, position: BlockPosition)

    func clearContents(contextId: BlockId, blockIds: [BlockId])
    func clearStyle(contextId: BlockId, blocksIds: [BlockId])
}

final class BlockTableService: BlockTableServiceProtocol {
    func createTable(
        contextId: BlockId,
        targetId: BlockId,
        position: BlockPosition,
        rowsCount: Int,
        columnsCount: Int
    ) {
        let eventsBunch = Anytype_Rpc.BlockTable.Create.Service.invoke(
            contextID: contextId,
            targetID: targetId,
            position: BlockPosition.replace.asMiddleware,
            rows: UInt32(rowsCount),
            columns: UInt32(columnsCount),
            withHeaderRow: false
        )
            .getValue(domain: .simpleTablesService)
            .map { EventsBunch(event: $0.event) }

        eventsBunch?.send()
    }

    func rowListFill(
        contextId: BlockId,
        targetIds: [BlockId]
    ) {
        let eventsBunch = Anytype_Rpc.BlockTable.RowListFill.Service.invoke(
            contextID: contextId,
            blockIds: targetIds
        )
            .getValue(domain: .simpleTablesService)
            .map { EventsBunch(event: $0.event) }

        eventsBunch?.send()
    }

    func columnCreate(contextId: BlockId, targetId: BlockId, position: BlockPosition) {
        let eventsBunch = Anytype_Rpc.BlockTable.ColumnCreate.Service.invoke(
            contextID: contextId,
            targetID: targetId,
            position: position.asMiddleware
        )
            .getValue(domain: .simpleTablesService)
            .map { EventsBunch(event: $0.event) }

        eventsBunch?.send()
    }

    func rowCreate(contextId: BlockId, targetId: BlockId, position: BlockPosition) {
        let eventsBunch = Anytype_Rpc.BlockTable.RowCreate.Service.invoke(
            contextID: contextId,
            targetID: targetId,
            position: position.asMiddleware
        )
            .getValue(domain: .simpleTablesService)
            .map { EventsBunch(event: $0.event) }

        eventsBunch?.send()
    }

    func insertRow(contextId: BlockId, targetId: BlockId, position: BlockPosition) {
        let eventsBunch = Anytype_Rpc.BlockTable.RowCreate.Service.invoke(
            contextID: contextId,
            targetID: targetId,
            position: position.asMiddleware
        )
            .getValue(domain: .simpleTablesService)
            .map { EventsBunch(event: $0.event) }

        eventsBunch?.send()
    }

    func insertColumn(contextId: BlockId, targetId: BlockId, position: BlockPosition) {
        let eventsBunch = Anytype_Rpc.BlockTable.ColumnCreate.Service.invoke(
            contextID: contextId,
            targetID: targetId,
            position: position.asMiddleware
        )
            .getValue(domain: .simpleTablesService)
            .map { EventsBunch(event: $0.event) }

        eventsBunch?.send()
    }

    func deleteColumn(contextId: BlockId, targetId: BlockId) {
        let eventsBunch = Anytype_Rpc.BlockTable.ColumnDelete.Service.invoke(
            contextID: contextId,
            targetID: targetId
        )
            .getValue(domain: .simpleTablesService)
            .map { EventsBunch(event: $0.event) }

        eventsBunch?.send()
    }

    func columnDuplicate(contextId: BlockId, targetId: BlockId) {
        let eventsBunch = Anytype_Rpc.BlockTable.ColumnDuplicate.Service.invoke(
            contextID: contextId,
            targetID: targetId,
            blockID: targetId,
            position: BlockPosition.left.asMiddleware
        )
            .getValue(domain: .simpleTablesService)
            .map { EventsBunch(event: $0.event) }

        eventsBunch?.send()
    }

    func columnSort(contextId: BlockId, columnId: BlockId, blocksSortType: BlocksSortType) {
        let eventsBunch = Anytype_Rpc.BlockTable.Sort.Service.invoke(contextID: contextId, columnID: columnId, type: blocksSortType.asMiddleware)
            .getValue(domain: .simpleTablesService)
            .map { EventsBunch(event: $0.event) }

        eventsBunch?.send()
    }

    func columnMove(contextId: BlockId, targetId: BlockId, dropTargetID: BlockId, position: BlockPosition) {
        let eventsBunch = Anytype_Rpc.BlockTable.ColumnMove.Service.invoke(
            contextID: contextId,
            targetID: targetId,
            dropTargetID: dropTargetID,
            position: position.asMiddleware
        )
            .getValue(domain: .simpleTablesService)
            .map { EventsBunch(event: $0.event) }

        eventsBunch?.send()
    }

    func rowMove(contextId: BlockId, targetId: BlockId, dropTargetID: BlockId, position: BlockPosition) {
        let eventsBunch = Anytype_Rpc.Block.ListMoveToExistingObject.Service.invoke(
            contextID: contextId,
            blockIds: [targetId],
            targetContextID: contextId,
            dropTargetID: dropTargetID,
            position: position.asMiddleware
        )
            .getValue(domain: .simpleTablesService)
            .map { EventsBunch(event: $0.event) }

        eventsBunch?.send()
    }

    func deleteRow(contextId: BlockId, targetId: BlockId) {
        let eventsBunch = Anytype_Rpc.BlockTable.RowDelete.Service.invoke(
            contextID: contextId,
            targetID: targetId
        )
            .getValue(domain: .simpleTablesService)
            .map { EventsBunch(event: $0.event) }

        eventsBunch?.send()
    }

    func rowDuplicate(contextId: BlockId, targetId: BlockId) {
        let eventsBunch = Anytype_Rpc.BlockTable.RowDuplicate.Service.invoke(
            contextID: contextId,
            targetID: targetId,
            blockID: targetId,
            position: BlockPosition.bottom.asMiddleware
        )
            .getValue(domain: .simpleTablesService)
            .map { EventsBunch(event: $0.event) }

        eventsBunch?.send()
    }

    func clearContents(contextId: BlockId, blockIds: [BlockId]) {
        let eventsBunch = Anytype_Rpc.BlockText.ListClearContent.Service.invoke(
            contextID: contextId,
            blockIds: blockIds
        )
            .getValue(domain: .simpleTablesService)
            .map { EventsBunch(event: $0.event) }

        eventsBunch?.send()
    }

    func clearStyle(contextId: BlockId, blocksIds: [BlockId]) {
        let eventsBunch = Anytype_Rpc.BlockText.ListClearStyle.Service.invoke(
            contextID: contextId,
            blockIds: blocksIds
        )
            .getValue(domain: .simpleTablesService)
            .map { EventsBunch(event: $0.event) }

        eventsBunch?.send()
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
