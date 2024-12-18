import SwiftUI

struct HomeTabLeftToRightGesture: UIGestureRecognizerRepresentable {
    
    let onBegin: () -> Void
    let onChange: (_ translate: CGFloat, _ velocity: CGFloat) -> Void
    let onEnd: (_ translate: CGFloat, _ velocity: CGFloat) -> Void
    
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer()
        gesture.delegate = context.coordinator
        return gesture
   }
    
    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        let translation = recognizer.translation(in: nil)
        let velocity = recognizer.velocity(in: nil)
        
        switch recognizer.state {
        case .began:
            onBegin()
        case .changed:
            onChange(translation.x, velocity.x)
        case .ended:
            onEnd(translation.x, velocity.x)
        case .failed:
            onEnd(0, 0)
        case .possible:
            break
        case .cancelled:
            onEnd(0, 0)
        @unknown default:
            break
        }
    }
    
    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            
            guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return false }
            
            // Remove conflict with navigation swipe
            guard gestureRecognizer.location(in: nil).x > 35 else { return false }
            
            let translation = panGesture.translation(in: nil)
            // Only left to right
            return translation.x > 0
        }
    }
}
