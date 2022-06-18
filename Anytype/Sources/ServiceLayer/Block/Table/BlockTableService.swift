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
            columns: UInt32(columnsCount)
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
}
