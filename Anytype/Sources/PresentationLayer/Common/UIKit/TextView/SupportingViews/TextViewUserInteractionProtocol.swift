import Foundation

protocol TextViewUserInteractionProtocol: AnyObject {
    func didReceiveAction(_ action: CustomTextView.UserAction)
}
