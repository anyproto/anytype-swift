import Foundation
import SwiftUI

struct SegmentLineItem: Identifiable, Hashable {
    let color: Color
    let value: CGFloat
    
    var id: Int { hashValue }
}

struct SegmentLine: View {
    
    let items: [SegmentLineItem]
    
    var body: some View {
        GeometryReader { reader in
            
            let freeWidth = reader.size.width - CGFloat(items.count - 1) * 2.0
            let values = items.reduce(0, { $0 + $1.value})
            
            // Calculate proportional widths
            let calculatedWidths = items.map { item in
                (item.value / max(values, 1)) * freeWidth
            }
            
            // Find segments that would be too small
            let minWidth: CGFloat = 4
            let tooSmallCount = calculatedWidths.filter { $0 < minWidth }.count
            let reservedWidth = CGFloat(tooSmallCount) * minWidth
            let remainingWidth = freeWidth - reservedWidth
            
            // Scale down the larger segments to make room for minimum widths
            let largeSegmentsTotalValue = items.enumerated().reduce(0) { result, item in
                let (index, segment) = item
                return calculatedWidths[index] >= minWidth ? result + segment.value : result
            }
            
            let finalWidths = items.enumerated().map { index, item in
                if calculatedWidths[index] < minWidth {
                    return minWidth
                } else {
                    let proportionalWidth = (item.value / max(largeSegmentsTotalValue, 1)) * remainingWidth
                    return max(proportionalWidth, minWidth)
                }
            }
            
            HStack(spacing: 2) {
                ForEach(Array(items.enumerated()), id: \.element) { index, item in
                    item.color
                        .frame(width: finalWidths[index])
                        .cornerRadius(5, style: .continuous)
                }
            }
            
        }
        .frame(height: 27)
    }
}
