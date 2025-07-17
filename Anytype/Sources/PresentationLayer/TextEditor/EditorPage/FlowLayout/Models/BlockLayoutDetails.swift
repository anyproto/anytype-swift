struct BlockLayoutDetails: Equatable, Hashable {
    let id: String
    
    let allChilds: [AnyHashable]
    let indentations: [BlockIndentationStyle]
    let ownStyle: BlockIndentationStyle
}
