import Foundation
import Services

struct BlockWidgetInfo {
    let block: BlockWidget
    let source: WidgetSource
}

extension BlockWidgetInfo {
    
    // Checks available layout for source. Return fallback value if layout doen't support for source.
    var fixedLayout: BlockWidget.Layout {
        let availableLayout = source.availableWidgetLayout
        
        guard availableLayout.contains(block.layout) else {
            return source.availableWidgetLayout.first ?? .link
        }
        
        return block.layout
    }
}
