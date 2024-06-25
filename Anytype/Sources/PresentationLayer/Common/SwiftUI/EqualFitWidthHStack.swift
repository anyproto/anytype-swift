import Foundation
import SwiftUI

struct EqualFitWidthHStack: Layout {
    
    let spacing: CGFloat
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let totalSpacing = spacing * CGFloat(subviews.count - 1)
        let maxSize = maxSize(subviews: subviews, proposal: proposal, totalSpacing: totalSpacing)
        
        let width = maxSize.width * CGFloat(subviews.count) + totalSpacing
        
        return CGSize(
            width: width,
            height: maxSize.height
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        guard !subviews.isEmpty else { return }
        
        let totalSpacing = spacing * CGFloat(subviews.count - 1)
        let maxSize = maxSize(subviews: subviews, proposal: proposal, totalSpacing: totalSpacing)
        
        let placementProposal = ProposedViewSize(width: maxSize.width, height: maxSize.height)
        var x = bounds.minX
      
        for index in subviews.indices {
            subviews[index].place(
                at: CGPoint(x: x, y: bounds.midY),
                anchor: .leading,
                proposal: placementProposal
            )
            x += maxSize.width + spacing
        }
    }
    
    private func maxSize(subviews: Subviews, proposal: ProposedViewSize, totalSpacing: CGFloat) -> CGSize {
        
        let maxWidth: CGFloat
        if let proposalWidth = proposal.width {
            maxWidth = (proposalWidth - totalSpacing) / CGFloat(subviews.count)
        } else {
            maxWidth = .infinity
        }
        
        let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let maxSize: CGSize = subviewSizes.reduce(.zero) { currentMax, subviewSize in
            CGSize(
                width: min(max(currentMax.width, subviewSize.width), maxWidth),
                height: max(currentMax.height, subviewSize.height)
            )
        }

        return maxSize
    }
}
