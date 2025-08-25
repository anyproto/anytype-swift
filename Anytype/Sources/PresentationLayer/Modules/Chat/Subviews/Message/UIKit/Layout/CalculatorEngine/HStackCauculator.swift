import Foundation
import AnytypeCore

enum HStackCauculatorAlignment {
    case top
    case center
    case bottom
}

struct HStackCauculator: ViewCalculator {
    
    let alignment: HStackCauculatorAlignment
    let spacing: CGFloat
    let size: CGSize
    let frameWriter: (CGRect) -> Void
    let views: [any ViewCalculator]
    
    private let viewSizes: [CGSize]
    
    init(
        alignment: HStackCauculatorAlignment = .center,
        spacing: CGFloat = 0,
        frameWriter: @escaping (CGRect) -> Void = { _ in },
        @ArrayBuilder<ViewCalculator> viewBuilder: () -> [any ViewCalculator]
    ) {
        
        self.alignment = alignment
        self.spacing = spacing
        self.frameWriter = frameWriter
        self.views = viewBuilder()
        
        for view in views {
            
        }
        
        if views.isEmpty {
            self.size = .zero
        } else {
            
            self.viewSizes =
        
            let width: CGFloat = views.reduce(into: 0.0, { $0 += $1.size.width }) + (spacing * CGFloat(views.count - 1))
            let height = views.map { $0.size.height }.max() ?? 0
            self.size = CGSize(width: width, height: height)
        }
    }
    
    func sizeThatFits(_ size: CGSize) -> CGSize {
        
    }
    
    func setFrame(_ frame: CGRect) {
        frameWriter(frame)
        var freeFrame = frame
        for view in views {
            let y: CGFloat
            
            switch alignment {
            case .top:
                y = freeFrame.minY
            case .center:
                y = freeFrame.minY + (freeFrame.height - view.size.height) * 0.5
            case .bottom:
                y = freeFrame.maxY - view.size.height
            }
            
            let viewFrame = CGRect(
                origin: CGPoint(x: freeFrame.minX, y: y),
                size: view.size
            )
            view.setFrame(viewFrame)
            freeFrame = freeFrame.offsetBy(dx: viewFrame.maxX + spacing, dy: 0)
        }
    }
}
