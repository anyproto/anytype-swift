import Foundation
import SwiftUI


struct BottomAlertButttonStack: Layout {
    
    private let horizontalSpacing: CGFloat = 10
    private let verticalSpacing: CGFloat = 10
    
    // Additional spacing from subview.spacing doesn't support
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard subviews.count > 0 else { return .zero }
        
        let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let widthSpacing = horizontalSpacing * CGFloat(subviews.count - 1)
        let maxSize = maxSize(subviews: subviews)
        let width = maxSize.width * CGFloat(subviews.count) + widthSpacing
        
        guard let proposalWidth = proposal.width else {
            return CGSize(width: width, height: maxSize.height)
        }
        
        guard proposalWidth < width else {
            return CGSize(width: proposalWidth, height: maxSize.height)
        }
        
        let heightSpacing = verticalSpacing * CGFloat(subviews.count - 1)
        let height = subviewSizes.map { $0.height }.reduce(0, +) + heightSpacing
        
        return CGSize(width: proposalWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count > 0 else { return }
        
        let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let widthSpacing = horizontalSpacing * CGFloat(subviews.count - 1)
        let maxSize = maxSize(subviews: subviews)
        let width = maxSize.width * CGFloat(subviews.count) + widthSpacing
        
        if bounds.width >= width {
            return placeHorizontal(in: bounds, proposal: proposal, subviews: subviews, subviewSizes: subviewSizes, maxSize: maxSize)
        } else {
            return placeVertical(in: bounds, proposal: proposal, subviews: subviews, subviewSizes: subviewSizes)
        }
    }
    
    private func placeHorizontal(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, subviewSizes: [CGSize], maxSize: CGSize) {
        var nextX = bounds.minX
        
        let widthSpacing = horizontalSpacing * CGFloat(subviews.count - 1)
        let width = (bounds.width - widthSpacing) / CGFloat(subviews.count)
        let proposalSize = ProposedViewSize(width: width, height: bounds.height)
        
        for subview in subviews {
            subview.place(
                at: CGPoint(x: nextX, y: bounds.midY),
                anchor: .leading,
                proposal: proposalSize
            )
            nextX += (width + horizontalSpacing)
        }
    }
    
    private func placeVertical(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, subviewSizes: [CGSize]) {
        var nextY = bounds.minY
        
        for (index, subview) in subviews.enumerated() {
            let height = subviewSizes[index].height
            subview.place(
                at: CGPoint(x: bounds.midX, y: nextY),
                anchor: .top,
                proposal: ProposedViewSize(width: bounds.width, height: height)
            )
            nextY += (height + verticalSpacing)
        }
    }
    
    private func maxSize(subviews: Subviews) -> CGSize {
        let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let maxSize: CGSize = subviewSizes.reduce(.zero) { currentMax, subviewSize in
            CGSize(
                width: max(currentMax.width, subviewSize.width),
                height: max(currentMax.height, subviewSize.height))
        }

        return maxSize
    }
}

#Preview("Horizontal") {
    BottomAlertButttonStack {
        Color.red
            .frame(idealWidth: 50)
            .frame(height: 50)
        Color.green
            .frame(idealWidth: 30)
            .frame(height: 30)
        Color.blue
            .frame(idealWidth: 10)
            .frame(height: 30)
    }
    .frame(width: 250, height: 150)
    .background(Color.gray)
}

#Preview("Vertical") {
    BottomAlertButttonStack {
        Color.red
            .frame(idealWidth: 80, idealHeight: 50)
        Color.green
            .frame(idealWidth: 30, idealHeight: 30)
        Color.blue
            .frame(idealWidth: 10, idealHeight: 30)
    }
    .frame(width: 100, height: 150)
    .background(Color.gray)
}

#Preview("Horizontal Buttons") {
    BottomAlertButttonStack {
        StandardButton(.text("A"), style: .primaryLarge, action: {})
        StandardButton(.text("DEF"), style: .primaryLarge, action: {})
    }
    .background(Color.gray)
}


#Preview("Vertical Buttons") {
    BottomAlertButttonStack {
        StandardButton(.text("ABCABCABCABC"), style: .primaryLarge, action: {})
        StandardButton(.text("DEFDEFDEFDEFDEF"), style: .primaryLarge, action: {})
    }
    .frame(width: 300)
    .background(Color.gray)
}
