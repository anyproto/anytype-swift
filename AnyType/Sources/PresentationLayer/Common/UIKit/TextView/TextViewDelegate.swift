/// First responder change type.
enum TextViewFirstResponderChange {
    /// Become first responder.
    case become
    /// Resign first responder.
    case resign
}

/// Text view delegate.
protocol TextViewDelegate: AnyObject {
    /// Text view size changed.
    func sizeChanged()

    /// Text view become first responder.
    func changeFirstResponderState(_ change: TextViewFirstResponderChange)

    /// Text will begin editing
    func willBeginEditing()

    /// Text did begin editing
    func didBeginEditing()
}
