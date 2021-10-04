
enum EditorItem: Hashable {
    
    case header(ObjectHeader)
    case block(BlockViewModelProtocol)
    
    static func == (lhs: EditorItem, rhs: EditorItem) -> Bool {
        switch (lhs, rhs) {
        case let (.block(lhsBlock), .block(rhsBlock)):
            return lhsBlock.information.id == rhsBlock.information.id
        case let (.header(lhsHeader), .header(rhsHeader)):
            return lhsHeader == rhsHeader
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .block(block):
            hasher.combine(block.information.id)
        case let .header(header):
            hasher.combine(header)
        }
    }
}
