import Foundation

public struct BlockWidget: Hashable {
    
    public enum Layout {
        case link
        case tree
        case list
    }
    
    public let layout: Layout
    
    public init(layout: Layout) {
        self.layout = layout
    }
}
