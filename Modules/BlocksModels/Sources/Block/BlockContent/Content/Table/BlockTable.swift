import ProtobufMessages

// May be will be used furthure!!!

public struct BlockTableRow: Hashable {
    public let id: BlockId
    public let background: MiddlewareColor
}

public struct BlockTableColumn: Hashable {
    public let id: BlockId
    public let background: MiddlewareColor
}

public struct BlockTable: Hashable {
    public let rows: [BlockTableRow]
    public let columns: [BlockTableColumn]

    public init(
        rows: [BlockTableRow],
        columns: [BlockTableColumn]
    ) {
        self.rows = rows
        self.columns = columns
    }

    public static var empty: BlockTable {
        .init(
            rows: [],
            columns: []
        )
    }
}
