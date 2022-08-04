import Foundation
import UIKit

final class EditorBrowserView: UIView {
    
    var forwardTouchesView: UIView?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let forwardTouchesView = forwardTouchesView else {
            return super.hitTest(point, with: event)
        }
        return forwardTouchesView.hitTest(point, with: event) ?? forwardTouchesView
    }
}
