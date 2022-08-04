import Foundation
import UIKit

final class EditorBrowserView: UIView {
    
    // Forward touches for drag and drop.
    // When user move object to navigation bar or bottom bar,
    // scroll is disabled because collection don't get touch event.
    var forwardTouchesView: UIView?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let forwardTouchesView = forwardTouchesView else {
            return super.hitTest(point, with: event)
        }
        return forwardTouchesView.hitTest(point, with: event) ?? forwardTouchesView
    }
}
