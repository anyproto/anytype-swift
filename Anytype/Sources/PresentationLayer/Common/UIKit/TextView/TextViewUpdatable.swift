import UIKit


/// Type of update that applied to text view.
struct TextViewUpdate {
    let attributedString: NSAttributedString
    let auxiliary: Auxiliary
}

struct Auxiliary {
    var textAlignment: NSTextAlignment
    var tertiaryColor: UIColor?
}

/// Text view that can update itself content.
protocol TextViewUpdatable: AnyObject {
    /// Apply update to text view.
    /// - Parameter update: Update that applied to text view.
    func apply(update: TextViewUpdate)
}
