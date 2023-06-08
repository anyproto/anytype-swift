import UIKit

extension String {
    
    var leftIndented: String {
        return "      " + self
    }
    
    func image(fontPointSize: CGFloat) -> UIImage? {
        let font = UIFont.systemFont(ofSize: fontPointSize)
        let actualSize = NSString(string: self).boundingRect(with:  CGSize(width: CGFloat.greatestFiniteMagnitude,
                                                                           height: CGFloat.greatestFiniteMagnitude),
                                                             options: [.usesFontLeading, .usesLineFragmentOrigin],
                                                             attributes: [.font: font],
                                                             context: nil).size
        let rect = CGRect(origin: .zero, size: actualSize)
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { _ in
            (self as AnyObject).draw(in: rect, withAttributes: [.font: font])
        }
    }
    
    func isValidURL() -> Bool {
        guard !isEmpty,
              let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return false }
        let range = detector.rangeOfFirstMatch(
            in: self,
            range: NSRange(location: 0, length: count)
        )
        return range.location == 0 && range.length == count
    }
    
    func isValidPhone() -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
