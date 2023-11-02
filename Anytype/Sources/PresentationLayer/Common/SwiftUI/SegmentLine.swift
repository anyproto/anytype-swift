import Foundation
import SwiftUI

struct SegmentItem: Identifiable, Hashable {
    let color: Color
    let value: CGFloat
    let legend: String
    
    var id: Int { hashValue }
}

struct SegmentLine: View {
    
    let items: [SegmentItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            segmentLine
            legend
        }
    }
    
    @ViewBuilder
    private var segmentLine: some View {
        GeometryReader { reader in
            
            let freeWidth = reader.size.width - CGFloat(items.count - 1) * 2.0
            let values = items.reduce(0, { $0 + $1.value})
            let oneValueWidth = freeWidth / values
            
            HStack(spacing: 2) {
                ForEach(items, id:\.self) { item in
                    item.color
                        .frame(width: item.value * oneValueWidth)
                        .cornerRadius(5, style: .continuous)
                }
            }
            
        }
        .frame(height: 27)
    }
    
    @ViewBuilder
    private var legend: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id:\.self) { item in
                HStack(spacing: 10) {
                    Circle()
                        .fill(item.color)
                        .frame(width: 16, height: 16)
                    AnytypeText(item.legend, style: .caption1Medium, color: .Text.primary)
                }
            }
        }
    }
}
