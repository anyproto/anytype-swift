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
    typealias TextBlockContentType = TopLevel.AliasesMap.BlockContent.Text.ContentType
    private static let graphikLCGSemibold = "GraphikLCG-Semibold"
    private static let interRegular = "Inter-Regular"
    private static let interBold = "Inter-Bold"
    
    static var titleFont: UIFont {
        UIFont(name: graphikLCGSemibold, size: 34) ?? .preferredFont(forTextStyle: .largeTitle)
    }
    
    static var header1Font: UIFont {
        UIFont(name: graphikLCGSemibold, size: 28) ?? .preferredFont(forTextStyle: .title1)
    }
    
    static var header2Font: UIFont {
        UIFont(name: graphikLCGSemibold, size: 22) ?? .preferredFont(forTextStyle: .title2)
    }
    
    static var header3Font: UIFont {
        UIFont(name: interBold, size: 17) ?? .preferredFont(forTextStyle: .title3)
    }
    
    static var highlightFont: UIFont {
        UIFont(name: interRegular, size: 17) ?? .preferredFont(forTextStyle: .headline)
    }
    
    static var bodyFont: UIFont {
        UIFont(name: interRegular, size: 15) ?? .preferredFont(forTextStyle: .body)
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
        case .text, .checkbox, .bulleted, .numbered, .toggle, .callout, .header4:
            return .bodyFont
        }
    }
}
