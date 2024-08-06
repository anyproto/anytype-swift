import Foundation
import UIKit
import SwiftUI

final class DiscussionTextViewCoordinator: NSObject, UITextViewDelegate {
    
    @Binding private var editing: Bool
    
    init(editing: Binding<Bool>) {
        self._editing = editing
        super.init()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !editing {
            editing = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if editing {
            editing = false
        }
    }
}
