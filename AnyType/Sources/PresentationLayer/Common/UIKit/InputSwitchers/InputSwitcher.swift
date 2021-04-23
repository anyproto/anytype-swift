
import UIKit

class InputSwitcher {
    
    typealias Coordinator = TextView.UIKitTextView.Coordinator
    
    /// Switch inputs based on textView, accessoryView and inputView.
    /// Do not override this method until you rewrite everything on top of one input view and one accessory view.
    ///
    /// - Parameters:
    ///   - inputViewKeyboardSize: Size of keyboard input view. ( actually, default keyboard size ).
    ///   - animated: Use animation or not
    ///   - textView: textView which would reload input views.
    ///   - accessoryView: accessory view which will be taken in account in switching
    ///   - inputView: input view which will be taken in account in switching
     func switchInputs(_ inputViewKeyboardSize: CGSize,
                       animated: Bool,
                       textView: UITextView,
                       accessoryView: UIView?,
                       inputView: UIView?) {
        if let currentView = textView.inputView, let nextView = inputView, type(of: currentView) == type(of: nextView) {
            textView.inputView = nil
            textView.reloadInputViews()
            return
        }
        else {
            let size = inputViewKeyboardSize
            inputView?.frame = .init(x: 0, y: 0, width: size.width, height: size.height)
            textView.inputView = inputView
            textView.reloadInputViews()
        }
        
        if let accessoryView = accessoryView {
            textView.inputAccessoryView = accessoryView
            textView.reloadInputViews()
        }
    }
    
    // MARK: Subclassing
    /// Choose which keyboard you need to show.
    /// - Parameters:
    ///   - coordinator: current coordinator
    ///   - textView: current text view
    ///   - selectionLength: length of selection
    ///   - accessoryView: current accessory view.
    ///   - inputView: current input view.
    /// - Returns: A triplet of flag, accessory view and input view. Flag equal `shouldAnimate` and indicates if we need animation in switching.
    func variantsFromState(_ coordinator: Coordinator,
                           textView: UITextView,
                           selectionLength: Int,
                           accessoryView: UIView?,
                           inputView: UIView?) -> InputSwitcherTriplet? {
        .init(shouldAnimate: false, accessoryView: nil, inputView: nil)
    }
    
    /// Actually, switch input views.
    /// - Parameters:
    ///   - coordinator: Coordinator which will provide data to correct views.
    ///   - textView: textView which will handle input views.
    func switchInputs(_ coordinator: Coordinator,
                      textView: UITextView) {
        guard let triplet = self.variantsFromState(coordinator, textView: textView, selectionLength: textView.selectedRange.length, accessoryView: textView.inputAccessoryView, inputView: textView.inputView) else { return }
        
        let (shouldAnimate, accessoryView, inputView) = (triplet.shouldAnimate, triplet.accessoryView, triplet.inputView)
        
        if shouldAnimate {
            textView.inputAccessoryView = accessoryView
            textView.inputView = inputView
            textView.reloadInputViews()
        }
        
        self.didSwitchViews(coordinator, textView: textView)
    }
    
    /// When we switch views, we could prepare our views.
    /// - Parameters:
    ///   - coordinator: current coordinator
    ///   - textView: text view that switch views.
    func didSwitchViews(_ coordinator: Coordinator,
                        textView: UITextView) {}
}
