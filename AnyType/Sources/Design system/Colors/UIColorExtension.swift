//
//  UIColorExtension.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import UIKit


extension UIColor {
    
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
    }
    
    static func randomColor() -> UIColor {
        let random = { CGFloat(arc4random_uniform(256)) / 255.0 }
        return UIColor(red: random(), green: random(), blue: random(), alpha: 1)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb:Int = (Int)(r*0xff)<<16 | (Int)(g*0xff)<<8 | (Int)(b*0xff)<<0

        return String(format:"#%06x", rgb)
    }
    
    convenience init(hexString: String, alpha: CGFloat = 1) {
        let chars = Array(hexString.dropFirst())
        self.init(red:   .init(strtoul(String(chars[0...1]), nil ,16)) / 255,
                  green: .init(strtoul(String(chars[2...3]), nil ,16)) / 255,
                  blue:  .init(strtoul(String(chars[4...5]), nil ,16)) / 255,
                  alpha: alpha)
        
    }
    
    static var highlighterColor: UIColor {
        .init(red: 255.0/255.0, green: 181.0/255.0, blue: 34.0/255.0, alpha: 1)
    }
    
    static var textColor: UIColor {
        .init(red: 44.0/255.0, green: 43.0/255.0, blue: 39.0/255.0, alpha: 1)
    }
    
    static var secondaryTextColor: UIColor {
        .init(red: 172.0/255.0, green: 169.0/255.0, blue: 150.0/255.0, alpha: 1)
    }
    
    static var selectedItemColor: UIColor {
        .init(red: 229.0/255.0, green: 239.0/255.0, blue: 249.0/255.0, alpha: 1)
    }
    
    static var accentItemColor: UIColor {
        .orange
    }

    static var activeOrange: UIColor {
        .init(hexString: "#F6A927")
    }
    

    /// Color that can be used in case if we couldn't parse color from middleware
    static var defaultColor: UIColor {
        .grayscale90
    }

    /// Color that can be used in case if we couldn't parse color from middleware
    static var defaultBackgroundColor: UIColor {
        .white
    }
    
    static var lemonBackground: UIColor {
        UIColor(hexString: "#FEF9CC")
    }
    
    static var amberBackground: UIColor {
        UIColor(hexString: "#FEF3C5")
    }
    
    static var redBackground: UIColor {
        UIColor(hexString: "#FFEBE5")
    }
    
    static var pinkBackground: UIColor {
        UIColor(hexString: "#FEE3F5")
    }
    
    static var purpleBackground: UIColor {
        UIColor(hexString: "#F4E3FA")
    }
    
    static var ultramarineBackground: UIColor {
        UIColor(hexString: "#E4E7FC")
    }
    
    static var blueBackground: UIColor {
        UIColor(hexString: "#D6EFFD")
    }
    
    static var tealBackground: UIColor {
        UIColor(hexString: "#D6F5F3")
    }
    
    static var greenBackground: UIColor {
        UIColor(hexString: "#E3F7D0")
    }
    
    static var coldgrayBackground: UIColor {
        UIColor(hexString: "#EBEFF1")
    }
    
    static var grayscale90: UIColor {
        UIColor(hexString: "#2C2B27")
    }
    
    static var pureLemon: UIColor {
        UIColor(hexString: "#ECD91B")
    }
    
    static var pureAmber: UIColor {
        UIColor(hexString: "#FFB522")
    }
    
    static var pureRed: UIColor {
        UIColor(hexString: "#F55522")
    }
    
    static var purePink: UIColor {
        UIColor(hexString: "#E51CA0")
    }
    
    static var purePurple: UIColor {
        UIColor(hexString: "#AB50CC")
    }
    
    static var pureUltramarine: UIColor {
        UIColor(hexString: "#3E58EB")
    }
    
    static var pureBlue: UIColor {
        UIColor(hexString: "#2AA7EE")
    }
    
    static var pureTeal: UIColor {
        UIColor(hexString: "#0FC8BA")
    }
    
    static var green: UIColor {
        UIColor(hexString: "#5DD400")
    }
    
    static var coldgray: UIColor {
        UIColor(hexString: "#8C9EA5")
    }

    static var grayscale30: UIColor {
        .init(hexString: "#DFDDD0")
    }

    static var grayscale50: UIColor {
        .init(hexString: "#ACA996")
    }

    static var darkGreen: UIColor {
        .init(hexString: "#57C600")
    }

    static var grayscale10: UIColor {
        .init(hexString: "#F3F2EC")
    }

    // MARK: - Color for background

    static var grayscaleWhite: UIColor {
        .init(hexString: "#FFFFFF")
    }

    static var lightColdgray: UIColor {
        .init(hexString: "#EBEFF1")
    }

    static var lightLemon: UIColor {
        .init(hexString: "#FEF9CC")
    }

    static var lightAmber: UIColor {
        .init(hexString: "#FEF3C5")
    }

    static var lightRed: UIColor {
        .init(hexString: "#FFEBE5")
    }

    static var lightPink: UIColor {
        .init(hexString: "#FEE3F5")
    }

    static var lightPurple: UIColor {
        .init(hexString: "#F4E3FA")
    }

    static var lightUltramarine: UIColor {
        .init(hexString: "#E4E7FC")
    }

    static var lightBlue: UIColor {
        .init(hexString: "#D6EFFD")
    }

    static var lightTeal: UIColor {
        .init(hexString: "#D6F5F3")
    }

    static var lightGreen: UIColor {
        .init(hexString: "#E3F7D0")
    }

    static var pressed: UIColor {
        .init(hexString: "#867D42", alpha: 0.1)
    }
}
