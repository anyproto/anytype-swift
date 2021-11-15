import Foundation

extension NSAttributedString {
    var mutable: NSMutableAttributedString {
        NSMutableAttributedString(attributedString: self)
    }
    
    static var empty: NSAttributedString {
        NSAttributedString()
    }
}
