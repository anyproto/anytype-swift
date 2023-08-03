import Foundation

extension NSAttributedString {
    var mutable: NSMutableAttributedString {
        NSMutableAttributedString(attributedString: self)
    }
    
    static var empty: NSAttributedString {
        NSAttributedString()
    }
}

extension Sequence where Iterator.Element == NSAttributedString {
    func joined(with separator: NSAttributedString) -> NSAttributedString {
        return self.reduce(NSMutableAttributedString()) {
            (result, element) in
            if result.length > 0 {
                result.append(separator)
            }
            result.append(element)
            return result
        }
    }

    func joined(with separator: String = "") -> NSAttributedString {
        return self.joined(with: NSAttributedString(string: separator))
    }
}
