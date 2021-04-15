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
        .black
    }

    /// Color that can be used in case if we couldn't parse color from middleware
    static var defaultBackgroundColor: UIColor {
        .white
    }
}
