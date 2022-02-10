public extension BlockLink {
    enum Style {
        case page
        case dataview
        case archive
    }
}

public struct BlockLink: Hashable, Equatable {
    public var targetBlockID: String
    public var style: Style
    public var fields: [String: AnyHashable]
    
    public init(targetBlockID: String, style: Style, fields: [String : AnyHashable]) {
        self.targetBlockID = targetBlockID
        self.style = style
        self.fields = fields
    }
    
    public static func empty(style: Style) -> BlockLink {
        BlockLink(targetBlockID: "", style: style, fields: [:])
    }
}
