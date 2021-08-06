
enum DataSourceItem: Hashable {
    
    case header(ObjectHeaderProtocol)
    case block(BlockViewModelProtocol)
    
    static func == (lhs: DataSourceItem, rhs: DataSourceItem) -> Bool {
        switch (lhs, rhs) {
        case let (.block(lhsBlock), .block(rhsBlock)):
            return lhsBlock.information.id == rhsBlock.information.id
        case let (.header(lhsHeader), .header(rhsHeader)):
            return lhsHeader.id == rhsHeader.id
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .block(block):
            hasher.combine(block.information.id)
        case let .header(header):
            hasher.combine(header.id)
        }
    }
}
