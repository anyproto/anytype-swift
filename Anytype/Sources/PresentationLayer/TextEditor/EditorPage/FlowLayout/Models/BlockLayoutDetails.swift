struct BlockLayoutDetails: Equatable, Hashable {
    let id: String
    
    let allChildIds: [String]
    let indentations: [BlockIndentationStyle]
    let ownStyle: BlockIndentationStyle
}
