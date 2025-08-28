import Foundation
import AnytypeCore

enum HStackCauculatorAlignment {
    case top
    case center
    case bottom
}

final class HStackCauculator: ViewCalculator {
    
    let alignment: HStackCauculatorAlignment
    let spacing: CGFloat
    let views: [any ViewCalculator]
    
    private var size: CGSize?
    private var viewSizes: [CGSize] = []
    
    init(
        alignment: HStackCauculatorAlignment = .center,
        spacing: CGFloat = 0,
        @ArrayBuilder<ViewCalculator> viewBuilder: () -> [any ViewCalculator]
    ) {
        
        self.alignment = alignment
        self.spacing = spacing
        self.views = viewBuilder()
    }
    
    func sizeThatFits(_ targetSize: CGSize) -> CGSize {
        
        if let size {
            return size
        }
        
        let size: CGSize
        if views.isEmpty {
            size = .zero
        } else {
            var targetSize = targetSize
            
            self.viewSizes = [CGSize](repeating: .zero, count: views.count)
            
            let sortedViews = views.enumerated().sorted { l, r in l.1.layoutPriority() > r.1.layoutPriority() }
            
            for enumeratedView in sortedViews {
                let index = enumeratedView.0
                let view = enumeratedView.1
                let viewSize = view.sizeThatFits(targetSize)
                targetSize.width -= (viewSize.width + spacing)
                viewSizes[index] = viewSize
            }
            
            let width: CGFloat = viewSizes.reduce(into: 0.0, { $0 += $1.width }) + (spacing * CGFloat(views.count - 1))
            let height = viewSizes.map { $0.height }.max() ?? 0
            size = CGSize(width: width, height: height)
        }
        self.size = size
        return size
    }
    
    func setFrame(_ frame: CGRect) {
        var freeFrame = frame
        for (index, view) in views.enumerated() {
            let viewSize = viewSizes[index]
            let y: CGFloat
            
            switch alignment {
            case .top:
                y = freeFrame.minY
            case .center:
                y = freeFrame.minY + (freeFrame.height - viewSize.height) * 0.5
            case .bottom:
                y = freeFrame.maxY - viewSize.height
            }
            
            let viewFrame = CGRect(
                origin: CGPoint(x: freeFrame.minX, y: y),
                size: viewSize
            )
            view.setFrame(viewFrame)
            freeFrame = freeFrame.offsetBy(dx: viewFrame.width + spacing, dy: 0)
        }
    }
}
