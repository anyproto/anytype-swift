import Foundation

public struct BlockWidget: Hashable {
    
    public enum Layout {
        case link
        case tree
        case list
        case compactList
    }
    
    public let layout: Layout
    public let limit: Int
    public let viewId: String
    
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
