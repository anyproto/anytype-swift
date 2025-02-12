import UIKit

extension UIColor {
    var isTransparent: Bool {
        !self.cgColor.alpha.isEqual(to: 1)
    }
        
    static func randomColor() -> UIColor {
        let random = { CGFloat.random(in: 0...1) }
        return UIColor(red: random(), green: random(), blue: random(), alpha: 1)
    }
    
    var hexString: String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb:Int = (Int)(r*0xff)<<16 | (Int)(g*0xff)<<8 | (Int)(b*0xff)<<0

        return String(format:"#%06X", rgb)
    }
    
    convenience init(hexString: String, alpha: CGFloat = 1) {
        let chars = Array(hexString.dropFirst())
        self.init(red:   .init(strtoul(String(chars[0...1]), nil, 16)) / 255,
                  green: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                  blue:  .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                  alpha: alpha)
        
    }
    
    
    var dark: UIColor {
        resolvedColor(with: .init(userInterfaceStyle: .dark))
    }
    
    var light: UIColor {
        resolvedColor(with: .init(userInterfaceStyle: .light))
    }
    
    convenience init(light: UIColor, dark: UIColor) {
        self.init(dynamicProvider: {
            switch $0.userInterfaceStyle {
            case .light, .unspecified:
                return light
            case .dark:
                return dark
            @unknown default:
                return light
            }
        })
    }
}
