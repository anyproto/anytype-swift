import Foundation
import SwiftUI

struct MessageReplyGestureRecognizer: UIGestureRecognizerRepresentable {
    
    let handleAction: (_ gesture: UIPanGestureRecognizer) -> Void
    
    func makeUIGestureRecognizer(context: Context) -> some UIGestureRecognizer {
        let gesture = UIPanGestureRecognizer()
        gesture.delegate = context.coordinator
        return gesture
    }
    
    func handleUIGestureRecognizerAction(_ recognizer: UIGestureRecognizerType, context: Context) {
        guard let pan = recognizer as? UIPanGestureRecognizer else { return }
        handleAction(pan)
    }
    
    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }
    
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        
        // MARK: - UIGestureRecognizerDelegate

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer, let view = pan.view else {
                return true
            }
            
            let velocity = pan.velocity(in: view)
            
            let isHorizontal = abs(velocity.x) > abs(velocity.y)
            
            // deviation from the horizontal axis by no more than 25 degrees
            let angle = atan2(velocity.y, velocity.x) * 180 / .pi
            let withinDeviationAngle = (angle > 155 || angle < -155)
            
            return isHorizontal && withinDeviationAngle
        }
    }
}
