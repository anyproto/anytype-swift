//
//  UIFont+Typography.swift
//  AnyType
//
//  Created by Kovalev Alexander on 26.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit
import BlocksModels

extension UIFont {
    typealias TextBlockContentType = BlockContent.Text.ContentType

    private enum Graphik {
        static let graphikLCGSemibold = "GraphikLCG-Semibold"
    }

    private enum IBMPlexMono {
        static let regular = "IBMPlexMono-Regular"
    }

    private enum Inter {
        static let family = "Inter"
        static let regularFace = "Regular"
        static let medium = "Medium"
    }
    
    static var titleFont: UIFont {
        UIFont(name: Graphik.graphikLCGSemibold, size: 34) ?? .preferredFont(forTextStyle: .largeTitle)
    }
    
    static var header1Font: UIFont {
        UIFont(name: Graphik.graphikLCGSemibold, size: 28) ?? .preferredFont(forTextStyle: .title1)
    }
    
    static var header2Font: UIFont {
        UIFont(name: Graphik.graphikLCGSemibold, size: 22) ?? .preferredFont(forTextStyle: .title2)
    }
    
    static var header3Font: UIFont {
        let fontDescription = UIFontDescriptor(fontAttributes: [.family: Inter.family])
        let font = UIFont(descriptor: fontDescription, size: 17.0)

        return font.fontDescriptor.withSymbolicTraits(.traitBold).map { UIFont(descriptor: $0, size: 17.0) } ?? font
    }
    
    static var highlightFont: UIFont {
        let fontDescription = UIFontDescriptor(fontAttributes: [.family: Inter.family, .face: Inter.regularFace])
        return UIFont(descriptor: fontDescription, size: 17.0)
    }
    
    static var bodyFont: UIFont {
        let fontDescription = UIFontDescriptor(fontAttributes: [.family: Inter.family, .face: Inter.regularFace])
        return UIFont(descriptor: fontDescription, size: 15.0)
    }
    
    static var smallBodyFont: UIFont {
        let fontDescription = UIFontDescriptor(fontAttributes: [.family: Inter.family, .face: Inter.regularFace])
        return UIFont(descriptor: fontDescription, size: 13.0)
    }

    static var codeFont: UIFont {
        UIFont(name: IBMPlexMono.regular, size: 15) ?? .preferredFont(forTextStyle: .body)
    }
    
    static var captionFont: UIFont {
        let descriptior = UIFontDescriptor(fontAttributes: [.family: Inter.family, .face: Inter.medium])
        return UIFont(descriptor: descriptior, size: 13)
    }
    
    /// Get font for for text block type
    ///
    /// - Parameters:
    /// - textType: Text block style
    static func font(for textType: TextBlockContentType) -> UIFont {
        switch textType {
        case .title:
            return .titleFont
        case .header2:
            return .header2Font
        case .header3:
            return .header3Font
        case .header:
            return .header1Font
        case .quote:
            return .highlightFont
        case .text, .checkbox, .bulleted, .numbered, .toggle, .code, .header4:
            return .bodyFont
        }
    }
}
