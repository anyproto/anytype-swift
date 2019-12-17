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

        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

        return String(format:"#%06x", rgb)
    }
    
    convenience init(hexString: String, alpha: CGFloat = 1) {
        let chars = Array(hexString.dropFirst())
        self.init(red:   .init(strtoul(String(chars[0...1]), nil ,16)) / 255,
                  green: .init(strtoul(String(chars[2...3]), nil ,16)) / 255,
                  blue:  .init(strtoul(String(chars[4...5]), nil ,16)) / 255,
                  alpha: alpha)
        
    }
}
