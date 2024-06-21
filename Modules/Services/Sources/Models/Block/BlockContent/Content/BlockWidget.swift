import Foundation

public struct BlockWidget: Hashable, Sendable {
    
    public enum Layout: Sendable {
        case link
        case tree
        case list
        case compactList
    }
    
    public var layout: Layout
    public var limit: Int
    public var viewId: String
    
    public init(
        layout: BlockWidget.Layout,
        limit: Int,
        viewId: String
    ) {
        self.layout = layout
        self.limit = limit
        self.viewId = viewId
    }
}
