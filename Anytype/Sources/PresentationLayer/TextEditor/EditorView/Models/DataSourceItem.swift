
enum DataSourceItem: Hashable {
    
    case header(String)
    case block(BlockViewModelProtocol)
    
    static func == (lhs: DataSourceItem, rhs: DataSourceItem) -> Bool {
        switch (lhs, rhs) {
        case let (.block(lhsBlock), .block(rhsBlock)):
            return lhsBlock.information.id == rhsBlock.information.id
        case (.header, .header):
            return true
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .block(block):
            hasher.combine(block.information.id)
        case let .header(string):
            hasher.combine(string)
        }
    }
}
