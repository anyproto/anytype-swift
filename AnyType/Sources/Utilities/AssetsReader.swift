//
//  AssetsReader.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 29/09/2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import UIKit

class AssetsStorage {
    class AssetsReader<Resource> {
        class func path() -> String? {
            return nil
        }
        
        class func resource(path: String?) -> Resource? {
            return nil
        }
        
        class var Value: Resource? { self.resource(at: path()) }
    }
}

extension AssetsStorage.AssetsReader {
    class func resource(at: String?) -> Resource? {
        let thePath = self.path()?.appending("/")
        if let theAt = at {
            return self.resource(path: thePath?.appending(theAt))
        }
        return self.resource(path: thePath)
    }
}

extension AssetsStorage {
    class Images {
        class ImagesReader: AssetsReader<UIImage> {
            override class func resource(path: String?) -> UIImage? {
                path.flatMap{UIImage(named: $0)}
            }
        }
    }
}

extension AssetsStorage.Images {
    class Logo: ImagesReader {
        override class func path() -> String? {
            "logo-sign-part-mobile"
        }
    }
}

extension AssetsStorage {
    class Colors {
        class ColorsReader: AssetsReader<UIColor> {
            override class func resource(path: String?) -> UIColor? {
                path.flatMap{UIColor(named: $0)}
            }
        }
    }
}

extension AssetsStorage.Colors {
    class Main: ColorsReader {
        override class func path() -> String? {
            "Colors"
        }
        class var BackgroundColor: UIColor? { resource(at: "backgroundColor") }
        class var BrownMenu: UIColor? { resource(at: "BrownMenu") }
        class var GrayText: UIColor? { resource(at: "GrayText") }
        class var Yellow: UIColor? { resource(at: "yellow") }
    }
}

extension AssetsStorage {
    class Local {
        var bundle: Bundle? = nil
        class AssetsReader<Resource> {
            var path: String
            init(path: String) {
                self.path = path
            }
            func resource() -> Resource? { return nil }
        }
        var images: Images = .init() // (bundle: Bundle)
        var colors: Colors = .init() // (bundle: Bundle)
        var words: Localization = .init() // (bundle: Bundle)
    }
}

extension AssetsStorage.Local.AssetsReader where Resource == UIImage {
    var value: UIImage {
        UIImage(named: self.path) ?? UIImage()
    }
}

extension AssetsStorage.Local.AssetsReader where Resource == UIColor {
    var value: UIColor {
        UIColor(named: self.path) ?? UIColor.black
    }
}

import SwiftUI
extension AssetsStorage.Local.AssetsReader where Resource == Image {
    var value: Image {
        Image(self.path)
    }
}
extension AssetsStorage.Local.AssetsReader where Resource == Color {
    var value: Color {
        Color(self.path)
    }
}
extension AssetsStorage.Local.AssetsReader where Resource == String {
    var value: String {
        NSLocalizedString(self.path, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

// Signature:
// Assets -> (Type, String)
// images.logo.value
extension AssetsStorage.Local {
    struct Images {
        var logo = AssetsReader<Image>(path: "logo-sign-part-mobile")
    }
    struct Colors {
        struct Side {
            var backgroundColor = AssetsReader<Color>(path: "Colors/backgroundColor")
            var grayText = AssetsReader<Color>(path: "Colors/GrayText")
        }
        struct Main {
            var brownMenu = AssetsReader<Color>(path: "Colors/BrownMenu")
            var yellow = AssetsReader<Color>(path: "Colors/yellow")
        }
        var side = Side()
        var main = Main()
    }
    struct Localization {
        struct Greeting {
            var title = AssetsReader<String>(path: "Welcome to AnyType!")
        }
        var greeting = Greeting()
    }
}
