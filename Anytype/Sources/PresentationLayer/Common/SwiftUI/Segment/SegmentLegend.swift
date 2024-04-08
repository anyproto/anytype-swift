import Foundation
import SwiftUI

struct SegmentLegendItem: Identifiable, Hashable {
    let color: Color
    let legend: String
    
    var id: Int { hashValue }
}

struct SegmentLegend: View {
    
    let items: [SegmentLegendItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id:\.self) { item in
                HStack(spacing: 10) {
                    Circle()
                        .fill(item.color)
                        .frame(width: 16, height: 16)
                    AnytypeText(item.legend, style: .caption1Medium)
                        .foregroundColor(.Text.primary)
                }
            }
        }
    }
}
