import Foundation
import SwiftUI

struct RemoteStorageSegmentInfo {
    var currentUsage: CGFloat? = nil
    var currentLegend: String? = nil
    
    var otherUsages: [CGFloat] = []
    var otherLegend: String? = nil
    
    var free: CGFloat? = nil
    var freeLegend: String? = nil
}

struct RemoteStorageSegment: View {
    
    let segmentLineItems: [SegmentLineItem]
    let segmentLegendItems: [SegmentLegendItem]
    
    let showLegend: Bool
    
    init(model: RemoteStorageSegmentInfo, showLegend: Bool = true) {
        self.showLegend = showLegend
        
        segmentLineItems = .builder {
            model.currentUsage.map { SegmentLineItem(color: .Control.accent125, value: $0) }
            model.otherUsages.map { SegmentLineItem(color: .Control.accent50, value: $0) }
            model.free.map { SegmentLineItem(color: .Shape.secondary, value: $0) }
        }
        segmentLegendItems = .builder {
            model.currentLegend.map { SegmentLegendItem(color: .Control.accent125, legend: $0) }
            model.otherLegend.map { SegmentLegendItem(color: .Control.accent50, legend: $0) }
            model.freeLegend.map { SegmentLegendItem(color: .Shape.secondary, legend: $0) }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SegmentLine(items: segmentLineItems)
            if showLegend {
                Spacer.fixedHeight(16)
                SegmentLegend(items: segmentLegendItems)
            }
        }
    }
}
