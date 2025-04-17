import Foundation
import Services

struct BlockWidgetInfo: Equatable, Identifiable {
    let id: String
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
    
    var fixedLimit: Int {
        if block.layout.limits.contains(Int(block.limit)) {
            return Int(block.limit)
        }
        
        return block.layout.limits.first ?? 0
    }
    
    var widgetCreateType: WidgetCreateType {
        block.autoAdded ? .auto: .manual
    }
}
