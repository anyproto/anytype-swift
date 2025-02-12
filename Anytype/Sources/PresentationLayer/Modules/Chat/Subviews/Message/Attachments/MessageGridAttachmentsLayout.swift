import Foundation
import SwiftUI

struct MessageGridAttachmentsLayout: Layout {
    
    struct Cache {
        var rows: [RowCache]
    }
    
    struct RowCache {
        var items: Int
        var height: CGFloat
    }
    
    let spacing: CGFloat
    
    func makeCache(subviews: Subviews) -> Cache {
        Cache(
            rows: MessageAttachmentsGridLayoutBuilder.makeGridRows(countItems: subviews.count).map { RowCache(items: $0, height: 0) }
        )
    }
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        
        let width = proposal.width ?? .infinity
        
        for rowIndex in cache.rows.indices {
            let rowItems = cache.rows[rowIndex].items
            let rowHeight = (width - (rowItems - 1) * spacing) / CGFloat(rowItems)
            cache.rows[rowIndex].height = rowHeight
        }
        
        let height = cache.rows.reduce(0, { $0 + $1.height }) + (cache.rows.count - 1) * spacing
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        var prevIndex = 0
        var y: CGFloat = bounds.minY
        for cacheRow in cache.rows {
            let nextIndex = prevIndex + cacheRow.items
            let items = subviews[prevIndex..<nextIndex]
            prevIndex = nextIndex
            
            let placementProposal = ProposedViewSize(width: cacheRow.height, height: cacheRow.height)
            
            var x: CGFloat = bounds.minX
            
            for index in items.indices {
                items[index].place(
                    at: CGPoint(x: x, y: y),
                    anchor: .topLeading,
                    proposal: placementProposal
                )
                
                x += cacheRow.height + spacing
            }
            
            y += cacheRow.height + spacing
        }
    }
}
