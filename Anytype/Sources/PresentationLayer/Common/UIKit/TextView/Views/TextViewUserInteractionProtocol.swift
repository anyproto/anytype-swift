import Foundation

protocol TextViewUserInteractionProtocol: AnyObject {
    /// Handle action from text input
    /// - Parameters:
    ///   - action: Action
    /// - Returns: should change text
    @discardableResult func didReceiveAction(_ action: CustomTextView.UserAction) -> Bool
}
