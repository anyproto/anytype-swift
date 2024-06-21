import ProtobufMessages

public struct BlockTableRow: Hashable, Sendable {
    public let isHeader: Bool

    public init(isHeader: Bool) {
        self.isHeader = isHeader
    }
}

public extension Anytype_Model_Block.Content.TableRow {
    var blockContent: BlockContent { .tableRow(BlockTableRow(isHeader: isHeader)) }
}
