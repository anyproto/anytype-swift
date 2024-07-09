import Foundation
import UIKit
import SwiftUI

final class DiscussionTextViewCoordinator: NSObject, UITextViewDelegate {
    
    @Binding private var editing: Bool
    @Binding private var height: CGFloat
    
    private let maxHeight: CGFloat
    
    init(editing: Binding<Bool>, height: Binding<CGFloat>, maxHeight: CGFloat) {
        self._editing = editing
        self._height = height
        self.maxHeight = maxHeight
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
    
    func textViewDidChange(_ textView: UITextView) {
        
        let size = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: .infinity))
        var newHeight: CGFloat
        
        if size.height > maxHeight {
            textView.isScrollEnabled = true
            newHeight = maxHeight
        } else {
            textView.isScrollEnabled = false
            newHeight = size.height
        }
        
        if newHeight != height {
            height = newHeight
        }
    }
}
