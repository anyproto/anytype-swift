public extension BlockLink {
    enum Style: String {
        case page = "Page"
        case dataview
        case archive
    }
}

public struct BlockLink: Hashable {
    public var targetBlockID: String
    public var style: Style
    public var fields: [String: AnyHashable]
    
    public init(style: Style) {
        self.init(targetBlockID: "", style: style, fields: [:])
    }
    
    public init(targetBlockID: String, style: Style, fields: [String : AnyHashable]) {
        self.targetBlockID = targetBlockID
        self.style = style
        self.fields = fields
    }
}
