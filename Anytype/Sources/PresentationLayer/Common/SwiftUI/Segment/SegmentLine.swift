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
            let oneValueWidth = freeWidth / max(values, 1)
            
            HStack(spacing: 2) {
                ForEach(items, id:\.self) { item in
                    item.color
                        .frame(width: max(item.value * oneValueWidth, 4))
                        .cornerRadius(5, style: .continuous)
                }
            }
            
        }
        .frame(height: 27)
    }
}
