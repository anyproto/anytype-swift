import Foundation

public struct BlockWidget: Hashable {
    
    public enum Layout {
        case link
        case tree
    }
    
    let layout: Layout
    
    public init(layout: Layout) {
        self.layout = layout
    }
}
