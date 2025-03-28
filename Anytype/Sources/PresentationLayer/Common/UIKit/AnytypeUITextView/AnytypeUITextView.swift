import Foundation
import SwiftUI
import UIKit

protocol AnytypeUITextViewDelegate: AnyObject {
    func textViewPasteAction(_ textView: AnytypeUITextView, sender: Any?)
    func textViewHasPasteAction(_ textView: AnytypeUITextView) -> Bool
}

// Text view providing common additional logic:
// - Some of the text may not be editable
final class AnytypeUITextView: UITextView {
    
    private enum ValidateDirection {
        case `default`
        case left
        case right
    }
    
    var notEditableAttributes = [NSAttributedString.Key]()
    
    weak var anytypeDelegate: (any AnytypeUITextViewDelegate)?
    
    override func closestPosition(to point: CGPoint) -> UITextPosition? {
        let newPosition = super.closestPosition(to: point)
        
        guard let newPosition else { return nil }
        
        return validatePosition(newPosition: newPosition, direction: .default)
    }
    
    override func deleteBackward() {
        guard let selectedTextRange,
            let deleteStart = super.position(from: selectedTextRange.start, offset: -1) else {
            super.deleteBackward()
            return
        }
        
        guard let fixedStart = validatePosition(newPosition: deleteStart, direction: .left),
              let fixedEnd = validatePosition(newPosition: selectedTextRange.end, direction: .default) else {
            super.deleteBackward()
            return
        }
        
        guard !deleteStart.isEqual(fixedStart) || !fixedEnd.isEqual(selectedTextRange.end) else {
            super.deleteBackward()
            return
        }
        
        let location = self.offset(from: beginningOfDocument, to: fixedStart)
        let lenght = self.offset(from: fixedStart, to: fixedEnd)
        self.textStorage.replaceCharacters(in: NSRange(location: location, length: lenght), with: "")
        self.selectedRange = NSRange(location: location, length: 0)
        delegate?.textViewDidChange?(self)
    }
    
    override func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
        let newPosition = super.position(from: position, offset: offset)
        
        guard let newPosition else { return nil }
        
        return validatePosition(newPosition: newPosition, direction: .default)
    }
    
    override func position(from position: UITextPosition, in direction: UITextLayoutDirection, offset: Int) -> UITextPosition? {
        
        let newPosition = super.position(from: position, in: direction, offset: offset)
        
        guard let newPosition else { return nil }

        return validatePosition(newPosition: newPosition, direction: direction == .right ? .right : .left)
    }
    
    // MARK: - Private
    
    private func validatePosition(newPosition: UITextPosition, direction: ValidateDirection) -> UITextPosition? {
        
        let newOffset = self.offset(from: beginningOfDocument, to: newPosition)
        let textRange = NSRange(location: 0, length: self.textStorage.length)
        
        guard textRange.contains(newOffset) else { return newPosition }
        
        var effectiveRange = NSRange(location: 0, length: 0)
        
        for attribute in notEditableAttributes {
            
            let value = self.textStorage.attribute(attribute, at: newOffset, longestEffectiveRange: &effectiveRange, in: textRange)
            
            if value != nil {
                let isUpper: Bool
                
                switch direction {
                case .default:
                    isUpper = abs(effectiveRange.upperBound - newOffset) < abs(newOffset - effectiveRange.location)
                case .left:
                    isUpper = false
                case .right:
                    isUpper = true
                }
                return super.position(from: beginningOfDocument, offset: isUpper ? effectiveRange.upperBound : effectiveRange.location)
            }
        }
        
        return newPosition
    }
    
    override func paste(_ sender: Any?) {
        if let anytypeDelegate {
            anytypeDelegate.textViewPasteAction(self, sender: sender)
        } else {
            super.paste(sender)
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            if let anytypeDelegate {
                return anytypeDelegate.textViewHasPasteAction(self)
            }
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
