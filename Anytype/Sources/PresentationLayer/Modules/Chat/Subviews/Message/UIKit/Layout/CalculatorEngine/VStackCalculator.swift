import Foundation
import AnytypeCore

enum VStackCauculatorAlignment {
    case left
    case center
    case right
}

class VStackCalculator: ViewCalculator {
    
    let alignment: VStackCauculatorAlignment
    let spacing: CGFloat
    let frameWriter: (CGRect) -> Void
    let views: [any ViewCalculator]
    
    private var size: CGSize?
    private var viewSizes: [CGSize] = []
    
    init(
        alignment: VStackCauculatorAlignment = .center,
        spacing: CGFloat = 0,
        frameWriter: @escaping (CGRect) -> Void = { _ in },
        @ArrayBuilder<ViewCalculator> viewBuilder: () -> [any ViewCalculator]
    ) {
        
        self.alignment = alignment
        self.spacing = spacing
        self.frameWriter = frameWriter
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
                targetSize.height -= (viewSize.height + spacing)
                viewSizes[index] = viewSize
            }
            
            let height: CGFloat = viewSizes.reduce(into: 0.0, { $0 += $1.height }) + (spacing * CGFloat(views.count - 1))
            let width = viewSizes.map { $0.width }.max() ?? 0
            size = CGSize(width: width, height: height)
        }
        self.size = size
        return size
    }
    
    func setFrame(_ frame: CGRect) {
        frameWriter(frame)
        var freeFrame = frame
        for (index, view) in views.enumerated() {
            let viewSize = viewSizes[index]
            let x: CGFloat
            
            switch alignment {
            case .left:
                x = freeFrame.minX
            case .center:
                x = freeFrame.minX + (freeFrame.width - viewSize.width) * 0.5
            case .right:
                x = freeFrame.maxX - viewSize.width
            }
            
            let viewFrame = CGRect(
                origin: CGPoint(x: x, y: freeFrame.minY),
                size: viewSize
            )
            view.setFrame(viewFrame)
            freeFrame = freeFrame.offsetBy(dx: 0, dy: viewFrame.height + spacing)
        }
    }
}
